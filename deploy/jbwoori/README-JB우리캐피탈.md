# DLM 배포 가이드 — JB우리캐피탈

> 폐쇄망 Rocky Linux 9 / MariaDB 호스트 OS 직접 설치 / Docker 미설치
> 작성일: 2026-04-08 | 갱신: 2026-04-21

---

## 전체 흐름

```
개발PC (WSL)                       JB우리캐피탈 서버 (Rocky 9)
============                       ============================

deploy/jbwoori/ 폴더
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
deploy/jbwoori/
├── docker-rpms/                       ← Docker RPM 패키지 (Rocky 9 / EL9)
│   ├── containerd.io-2.2.2
│   ├── docker-ce-29.4.0
│   ├── docker-ce-cli-29.4.0
│   └── docker-compose-plugin-5.1.1
├── images/
│   ├── dlm-app.tar.gz                ← DLM 이미지 (~301MB)
│   └── dlm-privacy-ai.tar.gz        ← Privacy-AI 이미지 (~78MB)
├── docker-compose.jbwoori.yml        ← JB우리캐피탈 전용 Docker Compose
├── .env.jbwoori                      ← JB우리캐피탈 전용 환경변수
├── mariadb/
│   ├── DLM_DATABASE_INIT.sql         ← DB/계정 초기화 SQL (★ 변수 치환 후 실행)
│   ├── cotdl_dump.sql.data           ← DB 스키마 + 데이터
│   ├── custom-prod.cnf               ← MariaDB 권장 설정 (DBA 전달)
│   ├── DLM_DDL_MASTER_CORE.sql       ← 코어 테이블 마스터 DDL
│   ├── DLM_DDL_MASTER_ACCESSLOG.sql  ← 접속기록관리 테이블 (9개)
│   ├── DLM_DDL_MASTER_DISCOVERY.sql  ← PII 탐지 테이블 (8개)
│   ├── COTDL_BACKUP_RESTORE.txt      ← DB 백업/복원 가이드
│   └── patches/                      ← 스키마 패치 (고객사별)
├── dlm-agent/                        ← WAS 접속기록 에이전트 (선택)
│   ├── dlm-agent-1.0.0.jar
│   ├── dlm-agent.properties
│   ├── install.sh
│   └── README-Agent설치가이드.md
├── scripts/
│   ├── install-docker.sh             ← Docker 오프라인 설치 (Rocky 9)
│   └── deploy.sh                     ← DLM 배포 스크립트
└── README-JB우리캐피탈.md             ← 이 문서
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
sudo dnf install -y ./*.rpm
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

## 4. DDL 패치 적용

> **반드시 아래 순서대로 실행합니다.**

### STEP 1: 접속기록관리 테이블 (ACCESSLOG)

```bash
mysql -u cotdl -p cotdl < mariadb/DLM_DDL_MASTER_ACCESSLOG.sql
```

### STEP 2: PII 탐지 테이블 (DISCOVERY)

```bash
mysql -u cotdl -p cotdl < mariadb/DLM_DDL_MASTER_DISCOVERY.sql
```

### STEP 3: 고객사별 패치 (patches/ 하위 파일이 있는 경우)

```bash
# 예시 — 파일이 있는 경우만 실행
mysql -u cotdl -p cotdl < mariadb/patches/PATCH_파일명.sql
```

### 패치 검증

```bash
# 핵심 신규 테이블 확인
mysql -u cotdl -p -e "SHOW TABLES LIKE 'tbl_access_log%';" cotdl
mysql -u cotdl -p -e "SHOW TABLES LIKE 'tbl_discovery%';" cotdl

# 테이블 수 확인
mysql -u cotdl -p -e "SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema='cotdl';" cotdl
```

---

## 5. DLM 배포

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

## 6. tbl_piidatabase 설정 (★ 중요)

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

> **이전 버전에서 `localhost`로 동작했다면**: 그때 `network_mode: host`를 사용했을 가능성이 높습니다.
> 현재는 bridge 네트워크 방식이므로 `host.docker.internal`을 사용해야 합니다.

---

## 7. 환경변수 (.env.jbwoori)

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

수정 후 반영:
```bash
cd /app/Datablocks
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d
```

---

## 8. 동작 확인

```bash
docker ps

# 정상이면:
#  dlm-app          Up 3 minutes   0.0.0.0:8080->8080/tcp
#  dlm-privacy-ai   Up 2 minutes   0.0.0.0:8000->8000/tcp
```

브라우저 접속: `http://서버IP:8080`
- 기본 계정: `admin` / `admin1234`

---

## 9. 운영 명령어

### 기본 명령어

```bash
cd /app/Datablocks

# ─── 상태 확인 ───
docker ps
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# ─── 시작 / 중지 / 재시작 ───
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d       # 전체 시작
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down         # 전체 중지
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart      # 전체 재시작
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart dlm  # DLM만 재시작
```

### 단축 명령 등록 (권장)

```bash
cat >> ~/.bashrc << 'EOF'
alias dlm-ps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm"'
alias dlm-up='cd /app/Datablocks && docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d'
alias dlm-down='cd /app/Datablocks && docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down'
alias dlm-restart='cd /app/Datablocks && docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart'
alias dlm-restart-app='cd /app/Datablocks && docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart dlm'
alias dlm-restart-ai='cd /app/Datablocks && docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart dlm-privacy-ai'
alias dlm-log='docker logs -f dlm-app'
alias dlm-log-ai='docker logs -f dlm-privacy-ai'
EOF
source ~/.bashrc
```

### 로그 확인

```bash
docker logs -f dlm-app                              # DLM 실시간 로그
docker logs -f dlm-privacy-ai                       # Privacy-AI 실시간 로그
docker logs dlm-app --tail 50                       # 최근 50줄
docker logs --since 30m dlm-app                     # 최근 30분
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -20   # 최근 에러 20건
docker volume inspect dlm-app-logs --format '{{.Mountpoint}}'      # 로그 파일 위치
```

### 컨테이너 상세 정보

```bash
docker stats dlm-app dlm-privacy-ai                 # 리소스 사용량
docker exec -it dlm-app sh                          # DLM 쉘 진입
docker exec dlm-app env | grep -i "spring\|jasypt"  # 환경변수 확인
docker exec dlm-app sh -c 'cat < /dev/tcp/host.docker.internal/3306 && echo OK'  # DB 연결 테스트
docker system df                                     # 디스크 사용량
```

---

## 10. 패치 적용 (이미지 업데이트)

### 10-1. 개발PC에서 이미지 준비 (WSL)

```bash
cd /app/Datablocks

# 1. 코드 수정 후 이미지 빌드
docker compose build --no-cache dlm                    # DLM만 변경된 경우
docker compose build --no-cache dlm dlm-privacy-ai     # 둘 다 변경된 경우

# 2. 이미지 추출
docker save datablocks-dlm:latest | gzip > deploy/jbwoori/images/dlm-app.tar.gz
docker save datablocks-dlm-privacy-ai:latest | gzip > deploy/jbwoori/images/dlm-privacy-ai.tar.gz

# 3. Windows → USB로 복사
cp -r deploy/jbwoori/images/ /mnt/c/Users/사용자명/Desktop/jbwoori-patch/
```

### 10-2. JB우리캐피탈 서버에서 패치 적용

```bash
# 0. 현재 이미지 백업 (권장)
mkdir -p /app/backup
docker save datablocks-dlm:latest | gzip > /app/backup/dlm-app-backup-$(date +%Y%m%d).tar.gz

# 1. USB 파일을 서버로 복사
mkdir -p /tmp/patch
cp -r /media/usb/* /tmp/patch/

# 2. 현재 컨테이너 중지
cd /app/Datablocks
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down

# 3. 새 이미지 로드
docker load < /tmp/patch/dlm-app.tar.gz

# Privacy-AI도 변경된 경우:
docker load < /tmp/patch/dlm-privacy-ai.tar.gz

# 4. 컨테이너 재시작
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d

# 5. 동작 확인
docker ps
docker logs -f --tail 50 dlm-app
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -10
```

### 10-3. DB 패치가 있는 경우

```bash
# 순서: ACCESSLOG → DISCOVERY → 고객사 패치 순
mysql -u cotdl -p'!Dlm1234' cotdl < /tmp/patch/DLM_DDL_MASTER_ACCESSLOG.sql
mysql -u cotdl -p'!Dlm1234' cotdl < /tmp/patch/DLM_DDL_MASTER_DISCOVERY.sql
mysql -u cotdl -p'!Dlm1234' cotdl < /tmp/patch/PATCH_파일명.sql
```

### 10-4. 롤백 (문제 발생 시)

```bash
cd /app/Datablocks
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down
docker load < /app/backup/dlm-app-backup-20260410.tar.gz
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d
```

---

## 11. 서버 재부팅 시

Docker에 `restart: unless-stopped` 설정이 되어 있으므로:

```
서버 재부팅 → Docker 자동 시작 → DLM 컨테이너 자동 시작
```

확인:
```bash
sudo systemctl is-enabled docker       # enabled 이면 OK
sudo systemctl is-enabled mariadb      # enabled 이면 OK
```

---

## 12. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 웹 접속 안 됨 | 방화벽 | `firewall-cmd --permanent --add-port=8080/tcp && firewall-cmd --reload` |
| 로그인 후 에러 | DB 연결 실패 | `docker logs dlm-app --tail 50` 확인 |
| `Connection refused` | bind-address | MariaDB `bind-address = 0.0.0.0` 확인 |
| `Access denied` | DB 계정/비밀번호 | `.env.jbwoori`의 PRIVACY_AI_DB_PASSWORD 확인 |
| `Unknown database` | DB 미생성 | DLM_DATABASE_INIT.sql 재실행 |
| `ANSI_QUOTES` 에러 | sql_mode | DBA에게 custom-prod.cnf 전달 |
| Job 실행 시 DB 접속 실패 | tbl_piidatabase | hostname을 `host.docker.internal`로 변경 |
| 컨테이너 재시작 반복 | 메모리/에러 | `docker logs dlm-app` 확인 |
| 포트 충돌 | 기존 서비스 | `.env.jbwoori`에서 DLM_PORT 변경 |

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

## 13. 방화벽 설정 (Rocky 9)

```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload
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

DDL 패치
  ☐ mysql -u cotdl -p cotdl < DLM_DDL_MASTER_ACCESSLOG.sql
  ☐ mysql -u cotdl -p cotdl < DLM_DDL_MASTER_DISCOVERY.sql
  ☐ 고객사별 패치 실행 (있는 경우)
  ☐ 패치 검증 (테이블 수, 인덱스 확인)

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
