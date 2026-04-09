# DLM 배포 가이드 — iM캐피탈

> 폐쇄망 CentOS 7.9 / Docker 미설치 / MariaDB 설치됨
> 작성일: 2026-04-08

---

## 전체 흐름

```
개발PC (WSL)                       iM캐피탈 서버 (CentOS 7.9)
============                       ==========================

deploy/imcapital/ 폴더
    |                              [1] sudo bash scripts/install-docker.sh
    | USB 복사                         → Docker 오프라인 설치
    v
                                   [DB 서버]
                                   [2] MariaDB 설정 확인
                                   [3] DLM_DATABASE_INIT.sql 실행 (수동)
                                   [4] cotdl_dump.sql.data 임포트

                                   [WAS 서버]
                                   [5] bash scripts/deploy.sh
                                       → 이미지 로드 + 설정 + 실행
                                       |
                                       v
                                   +-------+    +-----------+
                                   |  DLM  |    | Privacy-AI|
                                   +---+---+    +-----+-----+
                                       |              |
                                       +--------------+
                                             |
                                        iM캐피탈 MariaDB
                                        (기존 설치됨)
```

### 요약

```
1. Docker 설치:  sudo bash scripts/install-docker.sh   (최초 1회)
2. DB 초기화:    MariaDB 설정 확인 + SQL 수동 실행
3. DLM 배포:     bash scripts/deploy.sh
4. 브라우저:     http://서버IP:8080
```

---

## 1. 배포 패키지 구성

```
deploy/imcapital/
├── docker-rpms/                    ← Docker RPM 패키지 (CentOS 7)
│   ├── containerd.io-1.6.33
│   ├── docker-ce-26.1.4
│   ├── docker-ce-cli-26.1.4
│   └── docker-compose-plugin-2.27.1
├── images/
│   ├── dlm-app.tar.gz             ← DLM 이미지 (301MB)
│   └── dlm-privacy-ai.tar.gz     ← Privacy-AI 이미지 (78MB)
├── docker-compose.imcapital.yml   ← iM캐피탈 전용 Docker Compose
├── .env.imcapital                 ← iM캐피탈 전용 환경변수 (★ 수정 대상)
├── mariadb/
│   ├── DLM_DATABASE_INIT.sql      ← DB/계정 초기화 SQL (★ 변수 치환 후 실행)
│   ├── cotdl_dump.sql.data        ← DB 스키마 + 데이터
│   └── custom-prod.cnf            ← MariaDB 권장 설정 (DBA 전달)
├── scripts/
│   ├── install-docker.sh          ← Docker 오프라인 설치 (CentOS 7)
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
docker --version          # Docker version 26.1.4
docker compose version    # Docker Compose version v2.27.1
```

### 수동 설치하는 경우

```bash
cd docker-rpms
sudo yum install -y ./*.rpm
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 3. DB 초기화 (DB 서버에서 수동 실행)

### STEP 1: MariaDB 필수 설정 확인

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
```

### STEP 2: DLM_DATABASE_INIT.sql 변수 치환

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

### STEP 3: SQL 실행

```bash
# DB/계정 생성
mysql -u root -p < mariadb/DLM_DATABASE_INIT.sql

# 스키마 + 데이터 임포트
mysql -u root -p cotdl < mariadb/cotdl_dump.sql.data
```

### STEP 4: 확인

```bash
mysql -u root -p -e "SHOW DATABASES;"                                  # cotdl, cotdlbk 보이면 OK
mysql -u root -p -e "SELECT User, Host FROM mysql.user WHERE User='cotdl';"  # cotdl 보이면 OK
```

### 네트워크 확인 (WAS 서버에서)

```bash
nc -zv [DB서버IP] 3306
# succeeded 나오면 OK
```

안 되면 방화벽 오픈 요청: `WAS서버IP → DB서버IP:3306`

---

## 4. DLM 배포 (WAS 서버에서 실행)

### 스크립트로 실행 (권장)

```bash
bash scripts/deploy.sh
```

실행하면 대화형으로 진행됩니다:

```
  DB 서버 IP [Enter=건너뛰기]:      ← DB IP 입력
  DB 포트 [Enter=3306 유지]:        ← 기본이면 Enter
  DB 비밀번호 [Enter=기본값 유지]:   ← 변경했으면 입력
  DLM 포트 [Enter=8080 유지]:       ← 충돌 시 변경
  Privacy-AI 포트 [Enter=8000 유지]:← 충돌 시 변경
```

스크립트가 자동으로 수행하는 작업:

| 순서 | 작업 |
|------|------|
| 1 | Docker 이미지 로드 |
| 2 | 설정 파일 /app/Datablocks/ 에 배치 |
| 3 | 환경변수 설정 (.env.imcapital) |
| 4 | 컨테이너 실행 + 헬스체크 |

---

## 5. 환경변수 (.env.imcapital)

수정이 필요한 항목만 ★ 표시:

```properties
# ★ DB 서버 IP
SPRING_DATASOURCE_URL=jdbc:mariadb://[DB서버IP]:3306/cotdl?serverTimezone=UTC&autoReconnect=true&allowMultiQueries=true
PRIVACY_AI_DB_HOST=[DB서버IP]

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
docker compose -f docker-compose.imcapital.yml down
docker compose -f docker-compose.imcapital.yml up -d
```

---

## 6. 동작 확인

```bash
docker ps

# 정상이면:
#  dlm-app          Up 3 minutes   0.0.0.0:8080->8080/tcp
#  dlm-privacy-ai   Up 2 minutes   0.0.0.0:8000->8000/tcp
```

브라우저 접속: `http://WAS서버IP:8080`
- 기본 계정: `admin` / `admin1234`

---

## 7. 운영 명령어

```bash
cd /app/Datablocks

# 상태 확인
docker ps

# 시작
docker compose -f docker-compose.imcapital.yml up -d

# 중지
docker compose -f docker-compose.imcapital.yml down

# 재시작 (DLM만)
docker compose -f docker-compose.imcapital.yml restart dlm

# 로그
docker logs -f dlm-app             # DLM 로그
docker logs -f dlm-privacy-ai     # AI 로그

# 로그 파일 위치 (호스트)
docker volume inspect dlm-app-logs
```

### 단축 명령 등록 (선택)

```bash
cat >> ~/.bashrc << 'EOF'
alias dlm-up='cd /app/Datablocks && docker compose -f docker-compose.imcapital.yml up -d'
alias dlm-down='cd /app/Datablocks && docker compose -f docker-compose.imcapital.yml down'
alias dlm-restart='cd /app/Datablocks && docker compose -f docker-compose.imcapital.yml restart'
alias dlm-log='docker logs -f dlm-app'
alias dlm-ps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
EOF
source ~/.bashrc
```

---

## 8. 서버 재부팅 시

```
서버 재부팅 → Docker 자동 시작 → DLM 컨테이너 자동 시작
```

확인:
```bash
sudo systemctl is-enabled docker
# enabled 이면 OK
```

---

## 9. 업데이트 (패치 적용)

> 상세 가이드: [docs/패치-배포-가이드.md](../../docs/패치-배포-가이드.md)

### 9-1. 개발PC에서 이미지 준비 (WSL)

```bash
cd /app/Datablocks

# 1. 코드 수정 후 이미지 빌드
docker compose build dlm                    # DLM만 변경된 경우
docker compose build dlm-privacy-ai         # Privacy-AI만 변경된 경우
docker compose build dlm dlm-privacy-ai     # 둘 다 변경된 경우

# 2. 이미지 추출
docker save datablocks-dlm:latest | gzip > dlm-app.tar.gz
docker save datablocks-dlm-privacy-ai:latest | gzip > dlm-privacy-ai.tar.gz   # AI 변경 시

# 3. 배포 폴더에 복사
cp dlm-app.tar.gz deploy/imcapital/images/

# 4. Windows → USB로 복사
cp -r deploy/imcapital/images/ /mnt/c/Users/사용자명/Desktop/imcapital-patch/
```

### 9-2. iM캐피탈 서버에서 패치 적용

```bash
# 1. USB 파일을 서버로 복사
mkdir -p /tmp/patch
cp -r /media/usb/* /tmp/patch/

# 2. 현재 컨테이너 중지
cd /app/Datablocks
docker compose -f docker-compose.imcapital.yml down

# 3. 새 이미지 로드
docker load < /tmp/patch/images/dlm-app.tar.gz
#  → "Loaded image: datablocks-dlm:latest" 메시지 확인

# Privacy-AI도 변경된 경우:
docker load < /tmp/patch/images/dlm-privacy-ai.tar.gz

# 4. 컨테이너 재시작
docker compose -f docker-compose.imcapital.yml up -d

# 5. 동작 확인
docker ps                          # 컨테이너 2개 Up 확인
docker logs dlm-app --tail 20      # 에러 없는지 확인
```

브라우저 접속: `http://서버IP:8080` → 로그인 → 변경 기능 확인

### 9-3. DB 패치가 있는 경우

이미지 교체 후, DB 서버에서 패치 SQL을 실행합니다:

```bash
mysql -u cotdl -p cotdl < /tmp/patch/mariadb/PATCH_YYYYMMDD_설명.sql
```

### 9-4. 롤백 (문제 발생 시)

```bash
# 패치 전에 미리 백업해 둔 이미지로 복원
cd /app/Datablocks
docker compose -f docker-compose.imcapital.yml down
docker load < dlm-app-backup-YYYYMMDD.tar.gz
docker compose -f docker-compose.imcapital.yml up -d
```

> **팁**: 패치 전에 현재 이미지를 백업하세요:
> `docker save datablocks-dlm:latest | gzip > dlm-app-backup-$(date +%Y%m%d).tar.gz`

---

## 10. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 웹 접속 안 됨 | 방화벽 | `firewall-cmd --permanent --add-port=8080/tcp && firewall-cmd --reload` |
| 로그인 후 에러 | DB 연결 실패 | `.env.imcapital`의 DB IP 확인 |
| `Connection refused` | DB 방화벽 | WAS→DB 3306 포트 오픈 |
| `Access denied` | DB 계정/비밀번호 | DLM_DATABASE_INIT.sql 재실행 또는 비밀번호 확인 |
| `Unknown database` | DB 미생성 | DLM_DATABASE_INIT.sql 재실행 |
| `ANSI_QUOTES` 에러 | sql_mode | DBA에게 custom-prod.cnf 전달 |
| 컨테이너 재시작 반복 | 메모리 | `docker logs dlm-app` 확인 |
| 포트 충돌 | 기존 서비스 | `.env.imcapital`에서 DLM_PORT 변경 |

### DB 계정 권한 문제 시

```sql
-- DB 서버에서 실행 (비밀번호는 사이트 지정 값으로)
GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'%' IDENTIFIED BY '[DLM_PW]';
FLUSH PRIVILEGES;
```

### 로그 확인

```bash
docker logs dlm-app --tail 50
docker logs dlm-privacy-ai --tail 50
docker logs dlm-app 2>&1 | grep -i "error\|exception"
```

---

## 11. 방화벽 설정 (CentOS 7)

```bash
# firewalld 사용하는 경우
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload

# iptables 사용하는 경우
sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
sudo service iptables save
```

---

## 체크리스트

```
Docker 설치 (최초 1회)
  ☐ sudo bash scripts/install-docker.sh 실행
  ☐ docker --version 확인
  ☐ docker compose version 확인
  ☐ systemctl is-enabled docker → enabled 확인

DB 준비 (DB 서버)
  ☐ MariaDB 설정 확인 (lower_case_table_names=1, ANSI_QUOTES)
  ☐ DLM_DATABASE_INIT.sql 변수 치환 완료
    - #{ROOT_PW}, #{DLM_DB}=cotdl, #{DLM_DB_BK}=cotdlbk
    - #{DLM_USER}=cotdl, #{DLM_PW}=사이트지정
  ☐ mysql -u root -p < DLM_DATABASE_INIT.sql 실행
  ☐ mysql -u root -p cotdl < cotdl_dump.sql.data 실행
  ☐ DB/계정 생성 확인 (SHOW DATABASES, SELECT User FROM mysql.user)
  ☐ WAS → DB 통신 확인 (nc -zv DB서버IP 3306)

DLM 배포 (WAS 서버)
  ☐ bash scripts/deploy.sh 실행
    ☐ 이미지 로드 완료
    ☐ DB IP 설정 완료
    ☐ DB 비밀번호 = DLM_DATABASE_INIT.sql의 #{DLM_PW}와 일치
    ☐ 포트 확인 (충돌 여부)
    ☐ 컨테이너 2개 Running 확인

동작 확인
  ☐ 브라우저 http://서버IP:8080 접속
  ☐ 로그인 성공 (admin / admin1234)
  ☐ 대시보드 정상 표시

운영 설정
  ☐ 방화벽 포트 오픈 확인
  ☐ 담당자에게 운영 명령어 전달
```
