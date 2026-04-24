# 운영 환경 배포 가이드

## 목차
1. [서버 준비](#1-서버-준비)
2. [파일 전송 방법](#2-파일-전송-방법)
3. [운영 환경 `.env` 설정](#3-운영-환경-env-설정)
4. [운영용 Compose 파일 이해](#4-운영용-compose-파일-이해)
5. [최초 배포 절차](#5-최초-배포-절차)
6. [무중단 배포 전략](#6-무중단-배포-전략)
7. [롤백 절차](#7-롤백-절차)
8. [이후 배포 (업데이트)](#8-이후-배포-업데이트)
9. [SSL/TLS 구성](#9-ssltls-구성)

---

## 1. 서버 준비

### 1.1 운영 서버 사양

| 항목 | 운영 환경 |
|------|---------|
| CPU | 8 Core |
| RAM | 64 GB |
| 디스크 | 200 GB+ SSD (NVMe 권장) |
| OS | Ubuntu 22.04 LTS 또는 Rocky Linux 8/9 |
| 네트워크 | 1 Gbps 이상 |

### 1.2 Ubuntu 22.04 LTS에 Docker 설치

```bash
# 기존 Docker 관련 패키지 제거
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# 필수 패키지 설치
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Docker 공식 GPG 키 추가
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Docker 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker Engine 설치
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 서비스 시작 및 자동 시작 등록
sudo systemctl enable --now docker

# 현재 사용자를 docker 그룹에 추가 (재로그인 필요)
sudo usermod -aG docker $USER
newgrp docker

# 설치 확인
docker --version
docker compose version
```

### 1.3 Rocky Linux 8/9에 Docker 설치

```bash
# 기존 podman 충돌 방지
sudo dnf remove -y podman buildah 2>/dev/null || true

# Docker 저장소 추가
sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Docker Engine 설치
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 서비스 시작
sudo systemctl enable --now docker

# 사용자 그룹 추가
sudo usermod -aG docker $USER
newgrp docker

# 방화벽 설정 (필요 시)
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --permanent --add-port=9000/tcp
# 3306은 외부에 열지 않는 것을 권장
sudo firewall-cmd --reload
```

### 1.4 서버 기본 보안 설정

```bash
# Ubuntu UFW 방화벽 설정
sudo ufw allow ssh
sudo ufw allow 8080/tcp    # DLM 메인
sudo ufw allow 8000/tcp    # AI 서비스
sudo ufw allow 9000/tcp    # Portainer (필요 시, VPN 내부만 허용 권장)
# 3306(MariaDB)은 외부 개방 금지
sudo ufw enable

# 스왑 설정 (메모리 부족 방지 안전망)
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 2. 파일 전송 방법

### 2.1 방법 1: SCP (단순 전송)

```bash
# 개발 서버에서 운영 서버로 전체 프로젝트 전송
scp -r /app/Datablocks/ user@운영서버IP:/app/Datablocks/

# 특정 파일만 전송 (업데이트 배포 시)
scp /app/Datablocks/DLM/build/libs/*.war user@운영서버IP:/app/Datablocks/DLM/build/libs/

# 압축 전송 (대용량 파일)
tar czf - /app/Datablocks/ | ssh user@운영서버IP "tar xzf - -C /app/"
```

### 2.2 방법 2: rsync (증분 전송, 권장)

```bash
# 최초 전체 전송
rsync -avz --progress \
  /app/Datablocks/ \
  user@운영서버IP:/app/Datablocks/

# 업데이트 시 변경된 파일만 전송 (빠름)
rsync -avz --progress \
  --exclude='.env' \
  --exclude='*/build/' \
  --exclude='*/__pycache__/' \
  --exclude='*/node_modules/' \
  /app/Datablocks/ \
  user@운영서버IP:/app/Datablocks/

# .env 파일은 별도로 전송 (내용 직접 작성 권장)
scp /app/Datablocks/.env user@운영서버IP:/app/Datablocks/.env
```

### 2.3 방법 3: Git (소스 코드 관리)

```bash
# 운영 서버에서 직접 클론
ssh user@운영서버IP
git clone <저장소-URL> /app/Datablocks
cd /app/Datablocks

# 업데이트 시
cd /app/Datablocks
git pull origin main

# .env와 dump 파일은 git에 없으므로 별도 전송
# cotdl_dump.sql.data, cotdl_users.sql.data는 보안 채널로 전송
```

> **TIP**: 운영 서버에서 git pull 방식을 사용할 경우, `.env`와 SQL 덤프 파일 관리 방법을 사전에 결정하세요. 이 파일들은 git 저장소에 올리면 안 됩니다.

---

## 3. 운영 환경 `.env` 설정

운영 환경용 `.env` 파일은 개발 환경과 별도로 작성합니다.

```bash
# 운영 서버에서 .env 파일 생성
vi /app/Datablocks/.env
chmod 600 /app/Datablocks/.env
```

### `.env` 파일 내용 (운영 환경)

```properties
# ==============================================================================
# DLM 환경 변수 - 운영 환경
# ==============================================================================

# --- Spring Boot ---
SPRING_PROFILES_ACTIVE=prod

# --- MariaDB Root 비밀번호 (강력한 비밀번호 사용!) ---
MARIADB_ROOT_PASSWORD=P@ssw0rd_Str0ng_R00t_2024!

# --- Spring Datasource ---
SPRING_DATASOURCE_URL=jdbc:mariadb://dlm-mariadb:3306/cotdl?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul&rewriteBatchedStatements=true

# --- DB 접속 계정 (v1.0.0 부터 평문 env, Jasypt 제거됨) ---
SPRING_DATASOURCE_USERNAME=cotdl
SPRING_DATASOURCE_PASSWORD=<고객사 실암호>    # ★ 반드시 교체

# --- DLM-Privacy-AI 설정 ---
PRIVACY_AI_DB_HOST=dlm-mariadb
PRIVACY_AI_DB_PORT=3306
PRIVACY_AI_DB_NAME=cotdl
PRIVACY_AI_DB_USER=cotdl
PRIVACY_AI_DB_PASSWORD=P@ssw0rd_Str0ng_Cotdl_2024!
PRIVACY_AI_DLM_API_URL=http://dlm-app:8080
PRIVACY_AI_DEBUG=false
```

> **경고**: 운영 환경에서 반드시 다음 항목을 변경하세요.
> - `MARIADB_ROOT_PASSWORD`: 강력한 비밀번호 (20자 이상, 특수문자 포함)
> - `PRIVACY_AI_DB_PASSWORD`: cotdl 계정 비밀번호 (DB 덤프 복원 후 변경)
> - `PRIVACY_AI_DEBUG=false`: 운영 환경에서는 반드시 false

---

## 4. 운영용 Compose 파일 이해

운영 환경에서는 두 개의 Compose 파일을 함께 사용합니다.

```bash
# 기본 파일
docker-compose.yml           # 서비스 정의, 네트워크, 볼륨

# 운영 오버라이드 파일
docker-compose.prod.yml      # 운영 전용 리소스 할당, JVM 옵션
```

### 오버라이드 내용 요약

| 항목 | 개발 (docker-compose.yml) | 운영 (+ docker-compose.prod.yml) |
|------|--------------------------|----------------------------------|
| MariaDB 설정 | custom.cnf (버퍼풀 2GB) | custom-prod.cnf (버퍼풀 6GB) |
| MariaDB 메모리 | 4GB (limit) | 10GB (limit) |
| DLM JVM 힙 | -Xms2g -Xmx8g | -Xms8g -Xmx16g |
| DLM 메모리 | 12GB (limit) | 24GB (limit) |
| AI 서비스 메모리 | 8GB (limit) | 20GB (limit) |

### 운영 환경 명령어 형식

```bash
# 운영 환경에서 모든 docker compose 명령에 두 파일을 명시
docker compose -f docker-compose.yml -f docker-compose.prod.yml [명령어]

# 편의를 위해 alias 설정 (선택사항)
echo 'alias dc-prod="docker compose -f /app/Datablocks/docker-compose.yml -f /app/Datablocks/docker-compose.prod.yml"' >> ~/.bashrc
source ~/.bashrc

# 이후 간단히 사용
# dc-prod up -d --build
```

---

## 5. 최초 배포 절차

### 5.1 배포 전 체크리스트

```bash
# [ ] 1. 운영 서버 접속 및 Docker 설치 확인
docker --version && docker compose version

# [ ] 2. 프로젝트 파일 전송 완료 확인
ls -la /app/Datablocks/
ls -la /app/Datablocks/mariadb/init/cotdl_dump.sql.data
ls -la /app/Datablocks/mariadb/init/cotdl_users.sql.data

# [ ] 3. .env 파일 설정 완료
cat /app/Datablocks/.env | grep -v PASSWORD  # 비밀번호 제외 확인

# [ ] 4. 포트 충돌 확인
ss -tlnp | grep -E '8080|8000|3306|9000'
# 아무것도 출력되지 않아야 함 (포트 미사용 상태)

# [ ] 5. 디스크 여유 공간 확인 (최소 20GB 필요)
df -h /
```

### 5.2 최초 배포 실행

```bash
cd /app/Datablocks

# 운영 환경으로 빌드 및 시작
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build

# 빌드 진행 상황 모니터링 (별도 터미널)
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f
```

### 5.3 MariaDB 초기화 확인

```bash
# MariaDB 초기화 완료 확인 (healthy 상태 대기)
watch docker compose ps
# STATUS가 "Up (healthy)"가 될 때까지 대기 (최대 5분)

# 초기화 스크립트 실행 확인
docker compose logs mariadb 2>&1 | grep "\[init\]"
# 예상 출력:
# [init] Timezone info loaded into MariaDB
# [init] Restoring cotdl database from dump...
# [init] cotdl database restored.
# [init] Creating cotdl users...
# [init] Users created. Verifying...

# DB 복원 확인
docker exec -it dlm-mariadb mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" \
  -e "SHOW DATABASES; USE cotdl; SHOW TABLES;" 2>/dev/null
```

> **중요**: MariaDB init 스크립트(`/docker-entrypoint-initdb.d/`)는 **볼륨이 비어있을 때만** 실행됩니다. 이미 데이터가 있는 볼륨에서는 실행되지 않습니다.

### 5.4 전체 서비스 기동 확인

```bash
# 모든 서비스 상태 확인
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps

# DLM Spring Boot 기동 확인
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs dlm 2>&1 | \
  grep -E "Started|ERROR|Exception"

# AI 서비스 헬스체크
curl http://localhost:8000/health

# 메인 애플리케이션 접근 확인
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8080/
```

---

## 6. 무중단 배포 전략

DLM은 단일 인스턴스이므로 완전한 무중단은 어렵지만, 중단 시간을 최소화하는 롤링 업데이트를 사용합니다.

### 6.1 DLM 단독 업데이트 (권장)

소스 코드만 변경된 경우 DLM 컨테이너만 재빌드합니다. MariaDB와 AI 서비스는 계속 실행됩니다.

```bash
cd /app/Datablocks

# 1단계: 새 코드 가져오기
git pull origin main
# 또는 rsync로 파일 동기화

# 2단계: DLM만 재빌드
docker compose -f docker-compose.yml -f docker-compose.prod.yml build dlm

# 3단계: DLM 컨테이너 교체 (약 30~90초 다운타임)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d dlm

# 4단계: 기동 확인
docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f dlm
# "Started DlmApplication" 메시지 확인
```

### 6.2 전체 서비스 재배포

```bash
cd /app/Datablocks

# 전체 재빌드 및 재시작
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d --build
```

### 6.3 배포 전 이미지 사전 빌드 (다운타임 최소화)

```bash
cd /app/Datablocks

# 1단계: 현재 서비스 실행 중 이미지만 미리 빌드
docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache dlm
# 빌드 중에도 기존 컨테이너는 계속 실행됨

# 2단계: 빌드 완료 후 컨테이너만 교체 (다운타임 최소화)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d dlm
```

---

## 7. 롤백 절차

### 7.1 이전 이미지로 롤백

배포 전 이미지를 태깅해 두면 빠른 롤백이 가능합니다.

```bash
# 배포 전 현재 이미지 태깅 (배포 전에 실행)
docker tag datablocks-dlm:latest datablocks-dlm:backup-$(date +%Y%m%d-%H%M%S)

# 배포 후 문제 발생 시 이전 이미지로 롤백
# 저장된 이미지 목록 확인
docker images | grep datablocks-dlm

# 이전 이미지로 컨테이너 실행
docker compose -f docker-compose.yml -f docker-compose.prod.yml stop dlm
docker tag datablocks-dlm:backup-20240101-120000 datablocks-dlm:latest
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d dlm
```

### 7.2 Git으로 소스 롤백 후 재빌드

```bash
cd /app/Datablocks

# 이전 커밋으로 돌아가기
git log --oneline -10    # 커밋 이력 확인
git checkout <이전-커밋-해시> -- DLM/src/   # 소스만 되돌리기

# 재빌드
docker compose -f docker-compose.yml -f docker-compose.prod.yml build --no-cache dlm
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d dlm
```

### 7.3 DB 롤백 (주의 필요)

```bash
# DB 롤백은 데이터 손실 위험이 있으므로 신중하게 결정
# 배포 전 DB 백업이 있는 경우:
docker exec -i dlm-mariadb mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" cotdl \
  < /backup/cotdl_pre_deploy_backup.sql
```

---

## 8. 이후 배포 (업데이트)

이미 MariaDB 데이터가 있는 상태에서 애플리케이션만 업데이트하는 경우입니다.

### 8.1 체크리스트

```bash
# [ ] 1. 현재 서비스 상태 확인
docker compose -f docker-compose.yml -f docker-compose.prod.yml ps

# [ ] 2. 배포 전 DB 백업 (권장)
docker exec dlm-mariadb mariadb-dump -u root -p"${MARIADB_ROOT_PASSWORD}" \
  --all-databases --single-transaction \
  > /backup/pre_deploy_$(date +%Y%m%d_%H%M%S).sql

# [ ] 3. 새 코드 동기화
cd /app/Datablocks && git pull origin main

# [ ] 4. 이전 이미지 백업 태깅
docker tag datablocks-dlm:latest datablocks-dlm:backup-$(date +%Y%m%d-%H%M%S)
```

### 8.2 업데이트 배포 실행

```bash
cd /app/Datablocks

# DLM만 업데이트 (DB와 AI 서비스는 계속 실행)
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d --build dlm

# 모든 서비스 업데이트 (DB 제외)
docker compose -f docker-compose.yml -f docker-compose.prod.yml \
  up -d --build dlm dlm-privacy-ai
```

---

## 9. SSL/TLS 구성

현재 DLM은 HTTP로 서비스됩니다. 운영 환경에서는 다음 방법 중 하나로 HTTPS를 구성합니다.

### 9.1 방법 1: Nginx Reverse Proxy (권장)

```bash
# Nginx 설치
sudo apt-get install -y nginx certbot python3-certbot-nginx

# Nginx 설정 파일 생성
sudo vi /etc/nginx/sites-available/dlm

# 설정 내용:
```

```nginx
server {
    listen 80;
    server_name dlm.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name dlm.example.com;

    ssl_certificate /etc/letsencrypt/live/dlm.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/dlm.example.com/privkey.pem;

    # DLM 메인 애플리케이션
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 300s;
        client_max_body_size 100M;
    }
}
```

```bash
# Nginx 설정 활성화
sudo ln -s /etc/nginx/sites-available/dlm /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx

# Let's Encrypt SSL 인증서 발급
sudo certbot --nginx -d dlm.example.com
```

### 9.2 방법 2: Spring Boot 내부 SSL 설정

`application.properties`에 SSL 설정을 추가하고 키스토어 파일을 제공합니다.

```properties
server.ssl.enabled=true
server.ssl.key-store=/app/keystore.p12
server.ssl.key-store-type=PKCS12
server.ssl.key-store-password=${SERVER_SSL_KEY_STORE_PASSWORD}   # env 로 주입 (평문 금지)
server.port=8443
```

> **TIP**: 사내 인트라넷 서비스의 경우 방화벽으로 외부 접근을 차단하고 HTTP를 사용해도 무방합니다. 인터넷에 노출된 서비스는 반드시 HTTPS를 적용하세요.
