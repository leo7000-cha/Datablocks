# 배포 체크리스트 — JB우리캐피탈

> 작성일: 2026-04-27 | HTTPS 8443 기본 활성 패키지
> 자세한 절차는 `README-JB우리캐피탈.md` / `PROCEDURE.md` 참조

---

## 0. 환경 가정

| 항목 | 값 |
|---|---|
| OS | Rocky Linux 9 (폐쇄망) |
| MariaDB | 호스트 OS 직접 설치 (Docker 컨테이너 아님) |
| 서비스 포트 | HTTPS 8443 (메인), HTTP 8080 (리다이렉트), AI 8000 |
| DB 포트 | 3306 |
| 디스크 여유 | 최소 5GB (이미지 600MB + 로그/업로드 여유) |

---

## 1. 사전 점검 ★ (배포 전 반드시 확인)

### 1-1. 기존 Tomcat 8443 중지
```bash
sudo systemctl stop tomcat            # 또는 실제 서비스명
sudo systemctl disable tomcat
sudo ss -tlnp | grep 8443             # 출력 없어야 정상
```

### 1-2. MariaDB 실행 및 외부 접속 가능 여부
```bash
# (1) 실행 확인
sudo systemctl status mariadb

# (2) 모든 인터페이스에서 listen 중인지 (★ 컨테이너→호스트 접속 핵심)
sudo ss -tlnp | grep 3306
# → 0.0.0.0:3306 또는 *:3306 이어야 함
# → 127.0.0.1:3306 면 1-2-1 수정

# (3) cotdl 계정이 외부 호스트에서 접속 허용되는지
mysql -uroot -p'!Dlm1234' -e "SELECT User, Host FROM mysql.user WHERE User='cotdl';"
# → Host 컬럼에 '%' 또는 '172.17.0.%' 가 있어야 함
# → 'localhost' / '127.0.0.1' 만 있으면 1-2-2 수정
```

#### 1-2-1. bind-address 가 127.0.0.1 일 때
SELECT
  @@global.bind_address     AS bind_address,
  @@global.skip_networking  AS skip_networking,
  @@global.port             AS port,
  @@version                 AS version,
  @@version_compile_machine AS arch;
  
**기존 `server.cnf` 에 직접 추가** (표준 관행 — 별도 파일 만들지 말 것)

```bash
# (1) 현재 설정 확인 — bind-address 가 이미 있는지
sudo grep -in "bind" /etc/my.cnf.d/server.cnf

# (2) [mysqld] 섹션에 bind-address 한 줄 추가
sudo vi /etc/my.cnf.d/server.cnf
#   [mysqld] 아래에 다음 줄 추가:
#   bind-address = 0.0.0.0

# (3) 재시작 후 재확인
sudo systemctl restart mariadb
sudo ss -tlnp | grep 3306    # 0.0.0.0:3306 또는 *:3306 이어야 함
```

> ⚠️ `/etc/my.cnf.d/` 안의 모든 `*.cnf` 는 알파벳 순으로 로드되며 **나중에 읽힌 파일이 이김**. `server.cnf` 가 가장 뒤에 로드되므로 별도 파일(예: `bind.cnf`)을 만들면 server.cnf 의 기본값에 덮일 수 있음 — 그래서 server.cnf 에 직접 넣는 것이 안전.

#### 1-2-2. cotdl 계정 권한이 부족할 때
```bash
mysql -uroot -p'!Dlm1234' -e "
GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'%' IDENTIFIED BY '!Dlm1234';
FLUSH PRIVILEGES;
"
```

### 1-3. 방화벽 포트 오픈
```bash
sudo firewall-cmd --permanent --add-port=8443/tcp   # HTTPS 메인
sudo firewall-cmd --permanent --add-port=8080/tcp   # HTTP 리다이렉트
sudo firewall-cmd --permanent --add-port=8000/tcp   # Privacy-AI
sudo firewall-cmd --permanent --zone=trusted --add-interface=docker0   # docker→host DB
sudo firewall-cmd --reload
sudo firewall-cmd --list-all
```

### 1-4. 디스크 공간 확인
```bash
df -h /var/lib/docker /app
# → 각각 5GB 이상 여유 권장
```

---

## 2. 배포 순서 (3단계)

### STEP 1: Docker 설치 (최초 1회만)
```bash
cd /path/to/deploy/jbwoori
sudo bash scripts/install-docker.sh
docker --version       # 29.4.0 이상
docker compose version # v2.x 이상
```

### STEP 2: DB 초기화 (★ DDL DROP 검증 필수)
```bash
# (1) DDL 실행 전 DROP/TRUNCATE 검사
grep -iE 'DROP|TRUNCATE' database/ddl/*.sql database/ddl/patches/*.sql
# → 의도하지 않은 DROP 이 보이면 중단하고 검토 (COTDL 데이터 손실 사고 예방)

# (2) 스키마/계정 생성 → DDL 마스터 → 패치 → 초기 데이터 순서로 실행
#     상세 순서: PROCEDURE.md 참조
```

### STEP 3: DLM 배포
```bash
sudo bash scripts/deploy.sh
# 자동 수행:
#   - 8443 포트 충돌 사전 검사
#   - MariaDB 실행/bind 확인
#   - 이미지 로드 (dlm-app, dlm-privacy-ai)
#   - /app/Datablocks/ 에 compose + env + certs 배치
#   - 대화형 포트/비밀번호 설정
#   - 컨테이너 기동 + 헬스체크
```

---

## 3. 배포 직후 확인 (3가지)

```bash
# (1) 컨테이너 상태
docker ps | grep -E "dlm-app|dlm-privacy-ai"
# → 둘 다 Up 상태 + 8443/8080/8000 포트 매핑

# (2) HTTPS 접속
curl -kv https://localhost:8443/ 2>&1 | grep "HTTP/"
# → HTTP/1.1 302 (Location: /customLogin)

# (3) HTTP → HTTPS 자동 리다이렉트
curl -v http://localhost:8080/ 2>&1 | grep -E "HTTP/|Location:"
# → HTTP/1.1 302, Location: https://localhost:8443/
```

브라우저: `https://서버IP:8443` → admin / 1111
- 첫 접속 시 "안전하지 않음" 경고 → 고급 → 진행 (자체 서명 인증서)

---

## 4. 운영 인증서 교체 (받은 후)

```bash
# (1) PEM → PKCS12 변환
openssl pkcs12 -export \
  -in server.crt -inkey server.key -certfile ca-bundle.crt \
  -name dlm-keystore \
  -out /tmp/new-keystore.p12 \
  -passout pass:<운영비밀번호>

# (2) 호스트 마운트 위치에 동일 파일명으로 덮어쓰기 (★ 파일명 변경 금지)
sudo cp /tmp/new-keystore.p12 /app/Datablocks/certs/dlm-keystore.p12
sudo chmod 644 /app/Datablocks/certs/dlm-keystore.p12   # 컨테이너 내부 Java 가 non-root 유저라 644 필요 (keystore 는 비번으로 보호됨)

# (3) 비밀번호/alias 변경되었으면 .env.jbwoori 수정
sudo vi /app/Datablocks/.env.jbwoori
#   SERVER_SSL_KEY_STORE_PASSWORD=<운영비밀번호>
#   SERVER_SSL_KEY_PASSWORD=<운영비밀번호>
#   SERVER_SSL_KEY_ALIAS=dlm-keystore

# (4) DLM 만 재시작 (Privacy-AI 영향 없음, 다운타임 ~30초)
cd /app/Datablocks
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart dlm

# (5) 인증서 적용 확인
echo | openssl s_client -connect 서버IP:8443 2>/dev/null | openssl x509 -noout -subject -issuer -dates
```

---

## 5. 빠른 진단 (장애 발생 시)

### 5-1. 컨테이너가 안 뜸
```bash
docker logs dlm-app | tail -50
docker logs dlm-privacy-ai | tail -50
```

### 5-2. DB 접속 실패
```bash
# 컨테이너 → 호스트 DB 도달성
docker exec dlm-app sh -c 'cat < /dev/tcp/host.docker.internal/3306' 2>&1 | head -3
# → 응답 있으면 OK, "Connection refused" 면 1-2 재확인
```

### 5-3. HTTPS 접속 실패
```bash
# 인증서 확인
ls -la /app/Datablocks/certs/dlm-keystore.p12
# → 600 권한, 파일 존재해야 함

# Tomcat SSL 시작 로그
docker logs dlm-app 2>&1 | grep -iE "ssl|https|8443" | tail -10

# .env 비밀번호 일치 확인
grep SERVER_SSL_KEY_STORE_PASSWORD /app/Datablocks/.env.jbwoori
keytool -list -keystore /app/Datablocks/certs/dlm-keystore.p12 -storepass dlmssl
```

### 5-4. 8443 포트 충돌
```bash
sudo ss -tlnp | grep 8443
# → dlm-app 외 다른 프로세스가 보이면 그 프로세스 중지
```

---

## 6. 운영 명령어

```bash
cd /app/Datablocks

# 상태
docker ps | grep dlm
docker logs -f dlm-app                        # 실시간 로그

# 재시작 (DLM만)
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml restart dlm

# 전체 중지 / 시작
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml down
docker compose --env-file .env.jbwoori -f docker-compose.jbwoori.yml up -d
```

---

## 7. 최종 체크 ☐

```
사전 점검
  ☐ 기존 Tomcat 8443 중지 + disable
  ☐ ss -tlnp | grep 3306 → 0.0.0.0 또는 * 으로 listen
  ☐ cotdl 계정 Host = '%' 또는 '172.17.0.%'
  ☐ 방화벽 8443/8080/8000 오픈 + docker0 trusted
  ☐ /app, /var/lib/docker 디스크 5GB+ 여유

배포
  ☐ install-docker.sh 성공 (Docker 29.x)
  ☐ DDL DROP 검증 후 DB 초기화 완료
  ☐ deploy.sh 성공 (대화형 입력 완료)

배포 후
  ☐ docker ps → dlm-app, dlm-privacy-ai 모두 Up
  ☐ curl -kv https://localhost:8443 → HTTP/1.1 302
  ☐ curl -v http://localhost:8080 → HTTP/1.1 302 + Location: https://...:8443
  ☐ 브라우저 https://서버IP:8443 로그인 (admin/1111)
  ☐ tbl_piidatabase.hostname = 'host.docker.internal' 설정
  ☐ MariaDB 자동시작 등록 (systemctl is-enabled mariadb)
  ☐ 운영자에게 운영 명령어/인증서 교체 절차 전달
```
