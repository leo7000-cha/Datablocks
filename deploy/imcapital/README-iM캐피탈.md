# DLM 배포 가이드 — iM캐피탈

> Rocky 9 / MariaDB 호스트 OS 직접 설치 / Docker 미설치
> 작성일: 2026-04-08 | 갱신: 2026-04-10

---

## 전체 흐름

```
개발PC (WSL)                       iM캐피탈 서버 (Rocky 9)
============                       ==========================

deploy/imcapital/ 폴더
    |                              [1] sudo bash scripts/install-docker.sh
    | USB 복사                         → Docker 오프라인 설치
    v
                                   [2] MariaDB 설정 확인 (bind-address, ANSI_QUOTES)
                                   [3] DLM_DATABASE_INIT.sql 실행 (수동)
                                   [4] cotdl_dump.sql.data 임포트

                                   [5] bash scripts/deploy.sh
                                       → 이미지 로드 + 설정 + 실행
                                       |
                                       v
                                   +-------+    +-----------+
                                   |  DLM  |    | Privacy-AI|
                                   | :8080 |    |   :8000   |
                                   +---+---+    +-----+-----+
                                       |              |
                                       +--------------+
                                             |
                                     host.docker.internal:3306
                                             |
                                     호스트 OS의 MariaDB
```

### 네트워크 구조 (★ 핵심)

```
[dlm-app 컨테이너] → host.docker.internal:3306 → [호스트 OS] → MariaDB

  host.docker.internal = Docker가 호스트 OS IP로 자동 매핑하는 특수 DNS
  localhost            = 컨테이너 자기 자신 (MariaDB 없음 → 접속 실패)
```

### 요약

```
1. Docker 설치:  sudo bash scripts/install-docker.sh   (최초 1회)
2. DB 초기화:    MariaDB 설정 확인 + SQL 수동 실행
3. DLM 배포:     bash scripts/deploy.sh
4. DB 설정:      tbl_piidatabase.hostname = 'host.docker.internal'
5. 브라우저:     http://서버IP:8080
```

---

## 1. 배포 패키지 구성

```
deploy/imcapital/
├── docker-rpms/                    ← Docker RPM 패키지 (CentOS 9/Rocky 9)
│   ├── containerd.io-2.2.2
│   ├── docker-ce-29.4.0
│   ├── docker-ce-cli-29.4.0
│   └── docker-compose-plugin-5.1.1
├── images/
│   ├── dlm-app.tar.gz             ← DLM 이미지 (301MB)
│   └── dlm-privacy-ai.tar.gz     ← Privacy-AI 이미지 (78MB)
├── docker-compose.imcapital.yml   ← iM캐피탈 전용 Docker Compose
├── .env.imcapital                 ← iM캐피탈 전용 환경변수
├── mariadb/
│   ├── DLM_DATABASE_INIT.sql      ← DB/계정 초기화 SQL (★ 변수 치환 후 실행)
│   ├── cotdl_dump.sql.data        ← DB 스키마 + 데이터
│   └── custom-prod.cnf            ← MariaDB 권장 설정 (DBA 전달)
├── scripts/
│   ├── install-docker.sh          ← Docker 오프라인 설치
│   └── deploy.sh                  ← DLM 배포 스크립트
└── README-iM캐피탈.md              ← 이 문서
```

---

## 2. Docker 설치 (최초 1회)

```bash
sudo bash scripts/install-docker.sh
```

스크립트가 자동으로 수행하는 작업:

| 순서 | 작업 |
|------|------|
| 1 | 기존 Docker/Podman 제거 |
| 2 | RPM 패키지 설치 (containerd, docker-ce, docker-compose-plugin) |
| 3 | Docker 서비스 시작 + 자동시작 등록 |
| 4 | 방화벽 포트 오픈 (8080, 8000) |

### 설치 확인

```bash
docker --version          # Docker version 29.4.0
docker compose version    # Docker Compose version v5.1.1
```

### 수동 설치하는 경우

```bash
cd docker-rpms
sudo yum install -y ./*.rpm
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 3. DB 초기화

### STEP 1: MariaDB bind-address 확인 (★ 필수)

Docker 컨테이너에서 호스트 MariaDB에 접속하려면 `bind-address`가 `0.0.0.0`이어야 합니다.

```bash
mysql -u root -p -e "SHOW VARIABLES LIKE 'bind_address';"
```

| 현재 값 | 의미 | 조치 |
|---------|------|------|
| `0.0.0.0` | 모든 인터페이스 허용 | OK (변경 불필요) |
| `127.0.0.1` | 로컬만 허용 | ★ 변경 필요 |
| 비어있음 | 기본값 (모두 허용) | OK |

**변경 방법:**

```bash
# 기존 설정 파일 확인
ls /etc/my.cnf.d/

# 설정 추가 (파일이 없으면 새로 생성)
echo -e "[mysqld]\nbind-address = 0.0.0.0" | sudo tee /etc/my.cnf.d/bind.cnf

# MariaDB 재시작
sudo systemctl restart mariadb
```

### STEP 2: MariaDB 필수 설정 확인

```bash
mysql -u root -p -e "SHOW VARIABLES LIKE 'lower_case_table_names';"   # 반드시 1
mysql -u root -p -e "SHOW VARIABLES LIKE 'sql_mode';"                 # ANSI_QUOTES 포함 필수
mysql -u root -p -e "SHOW VARIABLES LIKE 'character_set_server';"     # utf8mb4 권장
```

설정이 안 되어 있으면 `mariadb/custom-prod.cnf`를 DBA에게 전달하고 적용 요청:

```ini
[mysqld]
lower_case_table_names = 1        ← 없으면 테이블 못 찾음
sql_mode = "ANSI_QUOTES,..."      ← 없으면 SQL 오류
character-set-server = utf8mb4     ← 한글 깨짐 방지
bind-address = 0.0.0.0             ← Docker 컨테이너 접속 허용
```

### STEP 3: DLM_DATABASE_INIT.sql 변수 치환

`mariadb/DLM_DATABASE_INIT.sql` 파일을 열어 아래 변수를 **사이트 값으로 치환(Replace All)** 합니다:

| 변수 | 설명 | 예시 |
|------|------|------|
| `#{ROOT_PW}` | root 비밀번호 | 사이트 root 비밀번호 |
| `#{DLM_DB}` | DLM 메인 DB명 | `cotdl` |
| `#{DLM_DB_BK}` | 백업 DB명 | `cotdlbk` |
| `#{DLM_USER}` | DLM 접속 사용자명 | `cotdl` |
| `#{DLM_PW}` | DLM 사용자 비밀번호 | 사이트에서 지정 |

> **주의**: `ALTER USER 'root'@'localhost'` 구문은 기존 MariaDB root 비밀번호를 변경합니다.
> 이미 root 비밀번호가 설정되어 있으면 해당 라인을 **주석 처리하거나 삭제**하고 실행하세요.

### STEP 4: SQL 실행

```bash
# DB/계정 생성
mysql -u root -p < mariadb/DLM_DATABASE_INIT.sql

# 스키마 + 데이터 임포트
mysql -u root -p cotdl < mariadb/cotdl_dump.sql.data
```

### STEP 5: 확인

```bash
mysql -u root -p -e "SHOW DATABASES;"                                  # cotdl, cotdlbk 보이면 OK
mysql -u root -p -e "SELECT User, Host FROM mysql.user WHERE User='cotdl';"  # cotdl 보이면 OK
```

---

## 4. DLM 배포

### 스크립트로 실행 (권장)

```bash
bash scripts/deploy.sh
```

스크립트 실행 흐름:

| 순서 | 작업 | 설명 |
|------|------|------|
| 1 | 사전 확인 | Docker 실행 + MariaDB 실행 + bind-address 체크 |
| 2 | Docker 이미지 로드 | dlm-app.tar.gz, dlm-privacy-ai.tar.gz |
| 3 | 설정 파일 배치 | /app/Datablocks/ 에 compose + env 복사 |
| 4 | 대화형 설정 | DB 포트, 비밀번호, 서비스 포트 변경 |
| 5 | 컨테이너 실행 | docker compose up -d + DB 연결 테스트 + 헬스체크 |

```
  MariaDB 포트 [Enter=3306 유지]:        ← 기본이면 Enter
  DB 비밀번호 [Enter=기본값 유지]:        ← 변경했으면 입력
  DLM 포트 [Enter=8080 유지]:            ← 충돌 시 변경
  Privacy-AI 포트 [Enter=8000 유지]:     ← 충돌 시 변경
```

---

## 5. tbl_piidatabase 설정 (★ 중요)

DLM이 Job 실행 시 대상 DB에 JDBC로 접속할 때 `tbl_piidatabase` 테이블의 `hostname` 컬럼을 사용합니다.

### hostname 설정 규칙

| hostname 값 | 동작 | 결과 |
|-------------|------|------|
| `host.docker.internal` | Docker → 호스트 OS → MariaDB | **정상** |
| `localhost` | 컨테이너 자기 자신 접속 | **실패** (MariaDB 없음) |
| 서버 IP (예: `10.x.x.x`) | 네트워크 경유 접속 | 동작하지만 비권장 |

### 설정 방법

```sql
-- 호스트 MariaDB에서 실행
UPDATE cotdl.tbl_piidatabase SET hostname = 'host.docker.internal' WHERE hostname = 'localhost';
```

### 확인

```sql
SELECT db, hostname, port FROM cotdl.tbl_piidatabase;
-- hostname이 모두 'host.docker.internal'인지 확인
```

### 왜 localhost가 안 되는가?

```
Docker 컨테이너 네트워크:
  localhost (127.0.0.1) → 컨테이너 자기 자신 (MariaDB 없음)
  host.docker.internal  → 호스트 OS의 IP (172.17.0.1 등) → MariaDB 있음

docker-compose.yml의 extra_hosts 설정이 이 매핑을 생성:
  extra_hosts:
    - "host.docker.internal:host-gateway"
```

> **이전 버전에서 `localhost`로 동작했다면**: 그때 `network_mode: host`를 사용했을 가능성이 높습니다.
> 현재는 bridge 네트워크 방식이므로 `host.docker.internal`을 사용해야 합니다.

---

## 6. 환경변수 (.env.imcapital)

수정이 필요한 항목만 ★ 표시:

```properties
# DB 접속 — host.docker.internal = 호스트 OS (수정 불필요)
SPRING_DATASOURCE_URL=jdbc:mariadb://host.docker.internal:3306/cotdl?...
PRIVACY_AI_DB_HOST=host.docker.internal

# ★ 포트 — 기존 서비스와 충돌 시 변경
DLM_PORT=8080
AI_PORT=8000

# ★ DB 비밀번호 — DLM_DATABASE_INIT.sql의 #{DLM_PW} 값과 일치해야 함
PRIVACY_AI_DB_PASSWORD=[DLM_PW와 동일한 비밀번호]
```

> **비밀번호 주의**: `DLM_DATABASE_INIT.sql`에서 `#{DLM_PW}`로 설정한 비밀번호와
> `.env.imcapital`의 `PRIVACY_AI_DB_PASSWORD` 값이 반드시 일치해야 합니다.

수정 후 반영:
```bash
cd /app/Datablocks
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml down
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml up -d
```

---

## 7. 동작 확인

```bash
docker ps

# 정상이면:
#  dlm-app          Up 3 minutes   0.0.0.0:8080->8080/tcp
#  dlm-privacy-ai   Up 2 minutes   0.0.0.0:8000->8000/tcp
```

브라우저 접속: `http://서버IP:8080`
- 기본 계정: `admin` / `admin1234`

---

## 8. 운영 명령어

### 기본 명령어

```bash
cd /app/Datablocks

# ─── 상태 확인 ───
docker ps                                            # 전체 컨테이너 상태
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"   # 간결하게

# ─── 시작 / 중지 / 재시작 ───
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml up -d       # 전체 시작
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml down         # 전체 중지
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml restart      # 전체 재시작
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml restart dlm  # DLM만 재시작
```

### 단축 명령 등록 (권장)

```bash
cat >> ~/.bashrc << 'EOF'
alias dlm-ps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm"'
alias dlm-up='cd /app/Datablocks && docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml up -d'
alias dlm-down='cd /app/Datablocks && docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml down'
alias dlm-restart='cd /app/Datablocks && docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml restart'
alias dlm-restart-app='cd /app/Datablocks && docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml restart dlm'
alias dlm-restart-ai='cd /app/Datablocks && docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml restart dlm-privacy-ai'
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

# ─── 최근 N줄 + 실시간 이어서 ───
docker logs -f --tail 100 dlm-app                   # 최근 100줄부터 실시간

# ─── 시간 기준 ───
docker logs --since 30m dlm-app                     # 최근 30분
docker logs --since 1h dlm-app                      # 최근 1시간

# ─── 에러만 필터 ───
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -20   # 최근 에러 20건

# ─── 로그 파일 위치 (호스트) ───
docker volume inspect dlm-app-logs --format '{{.Mountpoint}}'
```

### 컨테이너 상세 정보

```bash
# ─── 리소스 사용량 (실시간) ───
docker stats dlm-app dlm-privacy-ai                 # CPU / 메모리 / 네트워크

# ─── 컨테이너 내부 접속 ───
docker exec -it dlm-app sh                          # DLM 쉘 진입
docker exec -it dlm-privacy-ai bash                 # Privacy-AI 쉘 진입

# ─── 환경변수 확인 ───
docker exec dlm-app env | grep -i "spring\|jasypt"  # DLM 환경변수
docker exec dlm-privacy-ai env | grep -i "privacy"  # AI 환경변수

# ─── 호스트 DB 연결 테스트 (컨테이너 안에서) ───
docker exec dlm-app sh -c 'cat < /dev/tcp/host.docker.internal/3306 && echo OK'

# ─── 디스크 사용량 ───
docker system df                                     # Docker 전체 디스크 사용량
```

---

## 9. 패치 적용

### 9-1. 개발PC에서 이미지 준비 (WSL)

```bash
cd /app/Datablocks

# 1. 코드 수정 후 이미지 빌드
docker compose build --no-cache dlm                    # DLM만 변경된 경우
docker compose build --no-cache dlm dlm-privacy-ai     # 둘 다 변경된 경우

# 2. 이미지 추출
docker save datablocks-dlm:latest | gzip > deploy/imcapital/images/dlm-app.tar.gz
docker save datablocks-dlm-privacy-ai:latest | gzip > deploy/imcapital/images/dlm-privacy-ai.tar.gz

# 3. Windows → USB로 복사
cp -r deploy/imcapital/images/ /mnt/c/Users/사용자명/Desktop/imcapital-patch/
```

### 9-2. iM캐피탈 서버에서 패치 적용

```bash
# 0. 현재 이미지 백업 (권장)
mkdir -p /app/backup
docker save datablocks-dlm:latest | gzip > /app/backup/dlm-app-backup-$(date +%Y%m%d).tar.gz

# 1. USB 파일을 서버로 복사
mkdir -p /tmp/patch
cp -r /media/usb/* /tmp/patch/

# 2. 현재 컨테이너 중지
cd /app/Datablocks
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml down

# 3. 새 이미지 로드
docker load < /tmp/patch/dlm-app.tar.gz
#  → "Loaded image: datablocks-dlm:latest" 메시지 확인

# Privacy-AI도 변경된 경우:
docker load < /tmp/patch/dlm-privacy-ai.tar.gz

# 4. 컨테이너 재시작
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml up -d

# 5. 동작 확인
docker ps                                            # 컨테이너 2개 Up 확인
docker logs -f --tail 50 dlm-app                     # 로그 확인 (Ctrl+C 종료)
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -10   # 에러 확인
```

브라우저 접속: `http://서버IP:8080` → 로그인 → 변경 기능 확인

### 9-3. DB 패치가 있는 경우

```bash
mysql -u cotdl -p cotdl < /tmp/patch/PATCH_YYYYMMDD_설명.sql
```

### 9-4. 롤백 (문제 발생 시)

```bash
cd /app/Datablocks
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml down
docker load < /app/backup/dlm-app-backup-20260410.tar.gz
docker compose --env-file .env.imcapital -f docker-compose.imcapital.yml up -d
```

---

## 10. 서버 재부팅 시

Docker에 `restart: unless-stopped` 설정이 되어 있으므로:

```
서버 재부팅 → Docker 자동 시작 → DLM 컨테이너 자동 시작
```

확인:
```bash
sudo systemctl is-enabled docker       # enabled 이면 OK
```

> **주의**: MariaDB도 자동 시작이 설정되어 있어야 합니다:
> `sudo systemctl is-enabled mariadb` → enabled 확인

---

## 11. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 웹 접속 안 됨 | 방화벽 | `firewall-cmd --permanent --add-port=8080/tcp && firewall-cmd --reload` |
| 로그인 후 에러 | DB 연결 실패 | `docker logs dlm-app --tail 50` 확인 |
| `Connection refused` | bind-address | MariaDB `bind-address = 0.0.0.0` 확인 |
| `Access denied` | DB 계정/비밀번호 | `.env.imcapital`의 PRIVACY_AI_DB_PASSWORD 확인 |
| `Unknown database` | DB 미생성 | DLM_DATABASE_INIT.sql 재실행 |
| `ANSI_QUOTES` 에러 | sql_mode | DBA에게 custom-prod.cnf 전달 |
| Job 실행 시 DB 접속 실패 | tbl_piidatabase | hostname을 `host.docker.internal`로 변경 |
| 컨테이너 재시작 반복 | 메모리/에러 | `docker logs dlm-app` 확인 |
| 포트 충돌 | 기존 서비스 | `.env.imcapital`에서 DLM_PORT 변경 |

### 빠른 진단

```bash
# 1. 컨테이너 상태
docker ps -a | grep dlm

# 2. DLM 에러 확인
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -20

# 3. 호스트 DB 연결 테스트 (컨테이너 안에서)
docker exec dlm-app sh -c 'cat < /dev/tcp/host.docker.internal/3306 && echo OK || echo FAIL'

# 4. MariaDB bind-address 확인
mysql -u root -p -e "SHOW VARIABLES LIKE 'bind_address';"

# 5. tbl_piidatabase hostname 확인
mysql -u cotdl -p cotdl -e "SELECT db, hostname, port FROM tbl_piidatabase;"
```

---

## 12. 방화벽 설정 (Rocky 9)

```bash
# firewalld
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# 확인
sudo firewall-cmd --list-ports
```

---

## 체크리스트

```
Docker 설치 (최초 1회)
  ☐ sudo bash scripts/install-docker.sh 실행
  ☐ docker --version 확인
  ☐ docker compose version 확인
  ☐ systemctl is-enabled docker → enabled 확인

DB 준비
  ☐ MariaDB bind-address = 0.0.0.0 확인 (★ Docker 접속 필수)
  ☐ MariaDB 설정 확인 (lower_case_table_names=1, ANSI_QUOTES)
  ☐ DLM_DATABASE_INIT.sql 변수 치환 완료
    - #{ROOT_PW}, #{DLM_DB}=cotdl, #{DLM_DB_BK}=cotdlbk
    - #{DLM_USER}=cotdl, #{DLM_PW}=사이트지정
  ☐ mysql -u root -p < DLM_DATABASE_INIT.sql 실행
  ☐ mysql -u root -p cotdl < cotdl_dump.sql.data 실행
  ☐ DB/계정 생성 확인 (SHOW DATABASES, SELECT User FROM mysql.user)

DLM 배포
  ☐ bash scripts/deploy.sh 실행
    ☐ MariaDB 실행 확인 OK
    ☐ bind-address 경고 없음
    ☐ 이미지 로드 완료
    ☐ 포트 확인 (충돌 여부)
    ☐ 컨테이너 2개 Running 확인
    ☐ DB 연결 테스트 성공

DB 설정
  ☐ tbl_piidatabase.hostname = 'host.docker.internal' 확인 (★ 중요)

동작 확인
  ☐ 브라우저 http://서버IP:8080 접속
  ☐ 로그인 성공 (admin / admin1234)
  ☐ 대시보드 정상 표시
  ☐ Job 실행 테스트 (DB 접속 정상 확인)

운영 설정
  ☐ 방화벽 포트 오픈 확인
  ☐ MariaDB 자동시작 확인 (systemctl is-enabled mariadb)
  ☐ 담당자에게 운영 명령어/단축 명령 전달
```
