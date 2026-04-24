# DLM 배포 가이드 — 한국손사 (PROD: OS 설치형 MariaDB)

> 폐쇄망 Ubuntu / Docker 설치됨 / **MariaDB 는 호스트 OS 에 직접 설치**
> 작성일: 2026-04-08 | 갱신: 2026-04-22 (PROD 분기)

> 본 문서는 운영(PROD) 배포용입니다. MariaDB 가 Docker 컨테이너로 운영되는
> 개발(DEV) 환경 가이드는 [`../hanson_dev/README-한국손사.md`](../hanson_dev/README-한국손사.md) 를 참조하세요.

---

## DEV ↔ PROD 차이 요약

| 항목 | DEV (hanson_dev) | PROD (hanson_prod) |
|------|------------------|--------------------|
| MariaDB 설치 | Docker 컨테이너 | 호스트 OS (systemd) |
| DLM → DB 접속 호스트 | `mariadb` (컨테이너명) | `host.docker.internal` |
| Docker 네트워크 | 기존 mariadb 컨테이너 네트워크에 참여 | Compose 기본 브리지 |
| compose 추가 설정 | `networks.mariadb-net: external` | `extra_hosts: host-gateway` |
| deploy.sh 감지 로직 | mariadb 컨테이너/네트워크 자동 감지 | 호스트 MariaDB 연결 테스트 |
| DDL 패치 실행 | `docker exec mariadb mysql ...` | `mysql -h 127.0.0.1 ...` |
| tbl_piidatabase.hostname | `mariadb` | `host.docker.internal` |

---

## 전체 흐름

```
개발PC (WSL)                       손사 서버 (Ubuntu)
============                       ================

deploy/hanson_prod/ 폴더
    |                              호스트 OS 에 MariaDB 설치·운영 중
    | USB 복사                      (cotdl DB 구성 완료)
    v
                               [WAS 서버]
                               bash scripts/deploy.sh
                                   → 호스트 MariaDB 접속 정보 확인
                                   → 연결 테스트 (mysql 또는 nc)
                                   → 이미지 로드
                                   → DLM + Privacy-AI 실행
                                   |
                                   v
                               +-------+    +-----------+
                               |  DLM  |    | Privacy-AI|
                               | :8082 |    |   :8000   |
                               +---+---+    +-----+-----+
                                   |              |
                                   +──────┬───────+
                                          │  host.docker.internal
                                          │  (host-gateway 매핑)
                                          ▼
                                  호스트 OS MariaDB
                                  (OS 설치형, systemd)
```

### 요약

```
1. DB: 이미 구성 완료 (지난주 작업)
2. WAS 서버: bash scripts/deploy.sh   → DLM 실행 완료
3. 브라우저: http://WAS서버IP:8082     → 접속
```

---

## 1. 배포 패키지 구성

```
deploy/hanson_prod/
├── images/
│   ├── dlm-app.tar.gz                 ← DLM 이미지 (~301MB)
│   └── dlm-privacy-ai.tar.gz          ← Privacy-AI 이미지 (~78MB)
├── docker-compose.hanson.yml          ← PROD Compose (host-gateway)
├── .env.hanson                        ← PROD 환경변수 (host.docker.internal)
├── custom-prod.cnf                    ← MariaDB 권장 설정 (호스트 OS 적용)
├── database/
│   ├── init/                          ← DB/계정/초기데이터 SQL
│   ├── ddl/                           ← 코어/AccessLog/Discovery 마스터 DDL
│   ├── ddl/patches/                   ← 스키마 패치 (날짜별)
│   ├── batch-job/                     ← 배치 Job SQL
│   └── sql-workbook/                  ← 운영 쿼리 모음
├── scripts/
│   └── deploy.sh                      ← PROD 배포 스크립트 (OS MariaDB)
└── README-한국손사.md                 ← 이 문서
```

---

## 2. 사전 준비 — 호스트 MariaDB 설정 (★ PROD 전용)

### 2-1. bind-address 확인

DLM 컨테이너가 호스트 MariaDB 에 붙으려면 MariaDB 가 docker bridge 로부터의 TCP
접속을 수신해야 합니다.

```bash
# 현재 바인딩 확인
sudo grep -E "^bind-address" /etc/mysql/mariadb.conf.d/50-server.cnf
```

- `bind-address = 127.0.0.1` → 수정 필요 (컨테이너에서 붙을 수 없음)
- `bind-address = 0.0.0.0` → OK (단, 방화벽으로 외부 차단 필요)
- 권장: docker0 브리지 IP 만 바인딩 (예: `172.17.0.1`)

수정 후 반드시 재시작:
```bash
sudo systemctl restart mariadb
sudo ss -tlnp | grep 3306    # LISTEN 0.0.0.0:3306 또는 172.17.0.1:3306 확인
```

### 2-2. cotdl 계정 grant 확인

DLM 컨테이너는 docker bridge 대역(기본 172.17.0.0/16)에서 접속합니다.

```sql
-- 호스트에서 실행
mysql -u root -p

-- 현재 grant 확인
SELECT User, Host FROM mysql.user WHERE User = 'cotdl';

-- bridge 대역 허용이 없다면 추가 (예: 172.17.%)
CREATE USER IF NOT EXISTS 'cotdl'@'172.17.%' IDENTIFIED BY '!Dlm1234';
GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'172.17.%';
FLUSH PRIVILEGES;
```

> **주의**: docker bridge 네트워크를 커스텀으로 변경한 경우 그 대역에 맞게 grant 하세요.

### 2-3. MariaDB 설정 파일 적용 (선택)

`custom-prod.cnf` 의 설정을 호스트 MariaDB `/etc/mysql/mariadb.conf.d/` 아래에
배치하고 재시작하면 DLM 권장 튜닝이 적용됩니다.

---

## 3. 최초 배포 (deploy.sh)

```bash
bash scripts/deploy.sh
```

스크립트 실행 흐름:

| 순서 | 작업 | 설명 |
|------|------|------|
| 1 | 호스트 MariaDB 접속정보 확인 | 호스트/포트 입력 (기본 host.docker.internal:3306) |
| 2 | MariaDB 연결 테스트 | mysql 또는 nc 로 접근성 확인 |
| 3 | Docker 이미지 로드 | dlm-app.tar.gz, dlm-privacy-ai.tar.gz |
| 4 | 설정 확인 | 포트/호스트 최종 확인 후 .env 반영 |
| 5 | 컨테이너 실행 | docker compose up -d + 헬스체크 |

```
  ──────────────────────────────────────────
  MariaDB 호스트 설정 (Enter=유지, 입력=변경)
  ──────────────────────────────────────────

  MariaDB 호스트 [host.docker.internal]:  ← Enter (또는 호스트 실제 IP)
  MariaDB 포트   [3306]:                  ← Enter
  DLM 포트       [8082]:                  ← Enter
  Privacy-AI 포트 [8000]:                 ← Enter
```

---

## 4. DDL 패치 적용

> MariaDB 가 호스트 OS 에 설치되어 있으므로 **호스트에서 직접 mysql 클라이언트로** 실행합니다.

### 호스트에서 mysql 클라이언트로 실행

```bash
cd /app/Datablocks/deploy/hanson_prod

# ! 특수문자 때문에 MYSQL_PWD 환경변수로 비밀번호 전달 권장
export MYSQL_PWD='!Dlm1234'

# 패치 실행 (순서 중요!)
mysql -h 127.0.0.1 -u cotdl cotdl < database/ddl/DLM_DDL_MASTER_ACCESSLOG.sql
mysql -h 127.0.0.1 -u cotdl cotdl < database/ddl/DLM_DDL_MASTER_DISCOVERY.sql

# 고객사별 패치가 있는 경우:
# mysql -h 127.0.0.1 -u cotdl cotdl < database/ddl/patches/PATCH_파일.sql

unset MYSQL_PWD
```

> **대안**: mysql 클라이언트가 없다면 DLM 컨테이너 안에서 실행할 수 있습니다.
> ```bash
> docker exec -e MYSQL_PWD='!Dlm1234' -i dlm-app \
>     sh -c 'exec mysql -h host.docker.internal -u cotdl cotdl' \
>     < database/ddl/DLM_DDL_MASTER_ACCESSLOG.sql
> ```
> (단, dlm-app 이미지에 mysql client 가 포함된 경우에만)

### 패치 검증

```bash
export MYSQL_PWD='!Dlm1234'

# 핵심 신규 테이블 확인
mysql -h 127.0.0.1 -u cotdl cotdl -e "SHOW TABLES LIKE 'tbl_access_log%';"
mysql -h 127.0.0.1 -u cotdl cotdl -e "SHOW TABLES LIKE 'tbl_discovery%';"

# 테이블 수 확인
mysql -h 127.0.0.1 -u cotdl cotdl -e \
    "SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema='cotdl';"

unset MYSQL_PWD
```

---

## 5. 운영 명령어

### 기본 명령어

```bash
cd /app/Datablocks

# ─── 상태 확인 ───
docker ps                                            # 전체 컨테이너 상태
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"   # 간결하게

# ─── 시작 / 중지 / 재시작 ───
# .env.hanson 에 MARIADB_NETWORK 이 기록되어 있으므로 --env-file 로 전달
docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d       # 전체 시작
docker compose --env-file .env.hanson -f docker-compose.hanson.yml down         # 전체 중지
docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart      # 전체 재시작
docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart dlm  # DLM만 재시작
```

### 단축 명령 등록 (권장)

```bash
cat >> ~/.bashrc << 'EOF'
alias dlm-ps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm"'
alias dlm-up='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d'
alias dlm-down='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml down'
alias dlm-restart='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart'
alias dlm-restart-app='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart dlm'
alias dlm-restart-ai='cd /app/Datablocks && docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart dlm-privacy-ai'
alias dlm-log='docker logs -f dlm-app'
alias dlm-log-ai='docker logs -f dlm-privacy-ai'
EOF
source ~/.bashrc
```

등록 후:
```bash
dlm-ps             # 상태 확인
dlm-up             # 전체 시작
dlm-down           # 전체 중지
dlm-restart        # 전체 재시작
dlm-restart-app    # DLM만 재시작
dlm-restart-ai     # Privacy-AI만 재시작
dlm-log            # DLM 실시간 로그
dlm-log-ai         # Privacy-AI 실시간 로그
```

### 로그 확인

```bash
# ─── 실시간 로그 (Ctrl+C로 종료) ───
docker logs -f dlm-app                              # DLM 전체 로그
docker logs -f dlm-privacy-ai                       # Privacy-AI 전체 로그

# ─── 최근 N줄만 ───
docker logs dlm-app --tail 50                       # 최근 50줄
docker logs dlm-app --tail 100                      # 최근 100줄

# ─── 최근 N줄 + 실시간 이어서 ───
docker logs -f --tail 100 dlm-app                   # 최근 100줄부터 실시간

# ─── 시간 기준 ───
docker logs --since 30m dlm-app                     # 최근 30분
docker logs --since 1h dlm-app                      # 최근 1시간
docker logs --since 2h --until 1h dlm-app           # 2시간 전 ~ 1시간 전
docker logs --since "2026-04-09T09:00:00" dlm-app   # 특정 시각 이후

# ─── 에러만 필터 ───
docker logs dlm-app 2>&1 | grep -i "error"          # error 포함 라인
docker logs dlm-app 2>&1 | grep -i "exception"      # exception 포함 라인
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -20   # 최근 에러 20건

# ─── 로그 파일 위치 (호스트) ───
docker volume inspect dlm-app-logs --format '{{.Mountpoint}}'
# 예: /var/lib/docker/volumes/dlm-app-logs/_data/
```

### 컨테이너 상세 정보

```bash
# ─── 리소스 사용량 (실시간) ───
docker stats dlm-app dlm-privacy-ai                 # CPU / 메모리 / 네트워크

# ─── 컨테이너 내부 접속 ───
docker exec -it dlm-app sh                          # DLM 쉘 진입
docker exec -it dlm-privacy-ai bash                 # Privacy-AI 쉘 진입

# ─── 컨테이너 내부 파일 확인 ───
docker exec dlm-app ls -la /app/logs/               # 로그 파일 목록
docker exec dlm-app cat /app/logs/logback.2026-04-09.0.logger   # 특정 로그 파일

# ─── 환경변수 확인 ───
docker exec dlm-app env | grep -i "spring\|jasypt\|mail"       # DLM 환경변수
docker exec dlm-privacy-ai env | grep -i "privacy"             # AI 환경변수

# ─── 네트워크 확인 ───
docker network ls                                    # 네트워크 목록
docker network inspect <네트워크명>                    # 네트워크 상세 (연결된 컨테이너 목록)

# ─── 디스크 사용량 ───
docker system df                                     # Docker 전체 디스크 사용량
docker volume ls                                     # 볼륨 목록
```

### 이미지 관리

```bash
# ─── 현재 이미지 확인 ───
docker images | grep datablocks                      # DLM 관련 이미지

# ─── 오래된 이미지 정리 ───
docker image prune -f                                # 사용 안 하는 이미지 삭제
docker system prune -f                               # 미사용 컨테이너/네트워크/이미지 전부 정리

# ─── 현재 이미지 백업 (패치 전 필수!) ───
docker save datablocks-dlm:latest | gzip > /app/backup/dlm-app-backup-$(date +%Y%m%d).tar.gz
```

---

## 6. 패치 적용 (이미지 업데이트)

### 5-1. 개발PC에서 이미지 준비 (WSL)

```bash
cd /app/Datablocks

# 1. 코드 수정 후 이미지 빌드 (--no-cache 권장)
docker compose build --no-cache dlm                    # DLM만 변경된 경우
docker compose build --no-cache dlm dlm-privacy-ai     # 둘 다 변경된 경우

# 2. 이미지 추출
docker save datablocks-dlm:latest | gzip > deploy/hanson_prod/images/dlm-app.tar.gz
docker save datablocks-dlm-privacy-ai:latest | gzip > deploy/hanson_prod/images/dlm-privacy-ai.tar.gz

# 3. Windows → USB로 복사
cp -r deploy/hanson_prod/images/ /mnt/c/Users/사용자명/Desktop/hanson-patch/
```

### 5-2. 손사 서버에서 패치 적용

```bash
# 0. 현재 이미지 백업 (권장)
mkdir -p /app/backup
docker save datablocks-dlm:latest | gzip > /app/backup/dlm-app-backup-$(date +%Y%m%d).tar.gz

# 1. USB 파일을 서버로 복사
mkdir -p /tmp/patch
cp -r /media/usb/* /tmp/patch/

# 2. 현재 컨테이너 중지
cd /app/Datablocks
docker compose --env-file .env.hanson -f docker-compose.hanson.yml down

# 3. 새 이미지 로드
docker load < /tmp/patch/dlm-app.tar.gz
#  → "Loaded image: datablocks-dlm:latest" 메시지 확인

# Privacy-AI도 변경된 경우:
docker load < /tmp/patch/dlm-privacy-ai.tar.gz

# 4. 컨테이너 재시작
docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d

# 5. 동작 확인
docker ps                                            # 컨테이너 2개 Up 확인
docker logs -f --tail 50 dlm-app                     # 로그 확인 (Ctrl+C 종료)
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -10   # 에러 확인
```

브라우저 접속: `http://WAS서버IP:8082` → 로그인 → 변경 기능 확인

### 5-3. DB 패치가 있는 경우

```bash
# 호스트 OS 에서 직접 실행
export MYSQL_PWD='!Dlm1234'
mysql -h 127.0.0.1 -u cotdl cotdl < /tmp/patch/PATCH_YYYYMMDD_설명.sql
unset MYSQL_PWD
```

### 5-4. 롤백 (문제 발생 시)

```bash
cd /app/Datablocks
source .env.hanson

# 1. 문제 컨테이너 중지
docker compose --env-file .env.hanson -f docker-compose.hanson.yml down

# 2. 백업 이미지 복원
docker load < /app/backup/dlm-app-backup-20260409.tar.gz

# 3. 재시작
docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d

# 4. 확인
docker ps
docker logs -f --tail 50 dlm-app
```

---

## 7. 서버 재부팅 시

Docker 와 MariaDB 모두 systemd 서비스로 자동 시작되어야 합니다.

```
서버 재부팅 → systemd → mariadb 시작 + docker 시작
                                         │
                                         └→ DLM 컨테이너 자동 시작
                                             (restart: unless-stopped)
```

확인:
```bash
sudo systemctl is-enabled mariadb      # enabled 이면 OK (★ PROD 필수)
sudo systemctl is-enabled docker       # enabled 이면 OK
```

> **주의**: 호스트 MariaDB 가 먼저 Listen 상태가 되어야 DLM 이 DB에 접속 가능합니다.
> `mariadb.service` 가 disabled 이면 `sudo systemctl enable mariadb` 로 활성화하세요.
> DLM 컨테이너는 MariaDB 가 준비되기 전에 시작돼도 `autoReconnect=true` 로 재시도합니다.

---

## 8. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 웹 접속 안 됨 | 방화벽 | `sudo ufw allow 8082/tcp` |
| 로그인 후 에러 | DB 연결 실패 | `docker logs dlm-app --tail 50` 확인 |
| `Connection refused` | 호스트 MariaDB 미시작 or bind-address 문제 | `sudo systemctl status mariadb` / bind-address 확인 |
| `Access denied` | DB grant 불일치 (docker bridge 대역 미허용) | `SELECT User,Host FROM mysql.user WHERE User='cotdl';` |
| `Unknown host 'host.docker.internal'` | Docker Engine 버전이 오래됨 | Docker 20.10+ 필요 or `.env.hanson` 의 MARIADB_HOST 를 호스트 IP 로 변경 |
| 컨테이너 재시작 반복 | 메모리/에러 | `docker logs dlm-app` 확인 |
| 포트 충돌 | 기존 서비스 | `.env.hanson`에서 DLM_PORT 변경 |

### 빠른 진단

```bash
# 1. 컨테이너 상태
docker ps -a | grep dlm

# 2. 호스트 MariaDB 상태
sudo systemctl status mariadb --no-pager
sudo ss -tlnp | grep 3306                   # LISTEN 상태 확인

# 3. DLM 에러 확인
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -20

# 4. DLM 웹 응답
docker exec dlm-app sh -c "wget -qO- --timeout=3 http://localhost:8080/ && echo OK || echo FAIL"

# 5. 컨테이너 → 호스트 MariaDB 접속 테스트 (★ PROD 핵심)
docker exec dlm-app sh -c "nc -zv host.docker.internal 3306 2>&1 || echo 'DB 연결 실패'"

# 6. host.docker.internal 해석 확인
docker exec dlm-app sh -c "getent hosts host.docker.internal"
# → docker0 브리지 IP (예: 172.17.0.1) 가 나와야 정상

# 7. 호스트 MariaDB 계정/grant 확인
mysql -u root -p -e "SELECT User,Host FROM mysql.user WHERE User='cotdl';"
```

---

## 9. 방화벽 설정

```bash
# UFW
sudo ufw allow 8082/tcp    # DLM 웹
sudo ufw reload

# iptables
sudo iptables -A INPUT -p tcp --dport 8082 -j ACCEPT
```

> **MariaDB 3306 포트**: 외부에서의 접근은 차단하고 docker bridge (172.17.0.0/16)
> 에서만 허용하는 것이 안전합니다.
> ```bash
> sudo ufw allow from 172.17.0.0/16 to any port 3306
> ```

---

## 10. tbl_piidatabase 설정 (중요)

DLM 이 Job 실행 시 대상 DB 에 JDBC 로 접속할 때 `tbl_piidatabase` 테이블의 `hostname`
컬럼을 사용합니다.

### 네트워크 구조 (PROD)

```
[dlm-app 컨테이너] ──host.docker.internal:3306──→ [호스트 OS MariaDB]
                                                    (systemd)
```

### hostname 설정 규칙 (PROD)

| hostname 값 | 동작 | 결과 |
|-------------|------|------|
| `host.docker.internal` | host-gateway 로 호스트 MariaDB 접속 | **정상 (권장)** |
| 호스트 실제 IP (예: 10.0.0.5) | 동일하게 호스트 MariaDB 접속 | **정상** |
| `localhost` | dlm-app 컨테이너 자기 자신 접속 | **실패** (MariaDB 없음) |
| `mariadb` | Docker DNS 실패 (컨테이너 없음) | **실패** |

### 설정 방법

```sql
-- 호스트에서 mysql 클라이언트로 실행
UPDATE cotdl.tbl_piidatabase
   SET hostname = 'host.docker.internal'
 WHERE hostname IN ('localhost', 'mariadb');
```

### 확인

```sql
SELECT db, hostname, port FROM cotdl.tbl_piidatabase;
-- hostname이 모두 'host.docker.internal' (또는 호스트 IP) 인지 확인
```

> **주의**: DEV(컨테이너 MariaDB) 에서 복제한 DB 데이터에는 hostname 이 `mariadb` 로
> 들어가 있을 수 있습니다. PROD 로 이관했다면 위 UPDATE 문을 반드시 실행하세요.

---

## 체크리스트

```
사전 준비 (호스트 MariaDB)
  ☐ MariaDB systemd 서비스 Running
  ☐ bind-address 가 docker bridge 수신 가능 (0.0.0.0 또는 172.17.0.1)
  ☐ cotdl 계정 grant 에 172.17.% 포함
  ☐ systemctl is-enabled mariadb = enabled

최초 배포
  ☐ bash scripts/deploy.sh 실행
    ☐ MariaDB 연결 테스트 OK
    ☐ 이미지 로드 완료
    ☐ 포트 확인 (DLM=8082, AI=8000)
    ☐ 컨테이너 2개 Running
  ☐ DDL 패치 적용 (섹션 4 참고 — 호스트 mysql 클라이언트)
    ☐ DLM_DDL_MASTER_ACCESSLOG.sql 실행
    ☐ DLM_DDL_MASTER_DISCOVERY.sql 실행
    ☐ 고객사별 패치 실행 (있는 경우)
    ☐ 패치 검증 (테이블 수, 인덱스 확인)
  ☐ tbl_piidatabase.hostname = 'host.docker.internal' 확인 (★ 중요)
  ☐ 브라우저 http://WAS서버IP:8082 접속
  ☐ 로그인 성공 (admin / admin1234)
  ☐ Docker 자동시작 확인 (systemctl is-enabled docker)
  ☐ 방화벽 8082 포트 오픈
  ☐ 담당자에게 단축 명령 등록 안내

패치 적용
  ☐ 현재 이미지 백업
  ☐ 새 이미지 로드
  ☐ down → up
  ☐ 로그 에러 확인
  ☐ 브라우저 동작 확인
```
