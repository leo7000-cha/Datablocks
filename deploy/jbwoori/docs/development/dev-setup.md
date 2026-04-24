# 개발 환경 설정 가이드

## 목차
1. [사전 요구사항](#1-사전-요구사항)
2. [최초 환경 준비](#2-최초-환경-준비)
3. [`.env` 파일 설정](#3-env-파일-설정)
4. [빌드 및 시작](#4-빌드-및-시작)
5. [서비스 상태 확인](#5-서비스-상태-확인)
6. [로그 확인](#6-로그-확인)
7. [서비스 중지 및 재시작](#7-서비스-중지-및-재시작)
8. [개별 서비스 재빌드](#8-개별-서비스-재빌드)
9. [Portainer 접속](#9-portainer-접속)

---

## 1. 사전 요구사항

### 권장 개발 서버 사양

| 항목 | 최소 사양 | 권장 사양 |
|------|---------|---------|
| CPU | 4 Core | 8 Core |
| RAM | 16 GB | 32 GB |
| 디스크 | 50 GB | 100 GB SSD |
| OS | Ubuntu 20.04+ / Rocky Linux 8+ | Ubuntu 22.04 LTS |

### 필수 소프트웨어

| 소프트웨어 | 최소 버전 | 확인 명령 |
|-----------|---------|---------|
| Docker Engine | 24.0+ | `docker --version` |
| Docker Compose | 2.20+ (플러그인) | `docker compose version` |
| Git | 2.30+ | `git --version` |

> **주의**: Docker Compose V1 (`docker-compose` 명령)은 지원하지 않습니다. 반드시 Docker Compose V2 플러그인 (`docker compose`)을 사용하세요.

### Docker 설치 확인

```bash
# Docker 버전 확인
docker --version
# 예시: Docker version 25.0.3, build 4debf41

# Docker Compose 버전 확인
docker compose version
# 예시: Docker Compose version v2.24.5

# Docker 서비스 상태 확인
sudo systemctl status docker
```

### Docker 설치 (미설치 시)

```bash
# Ubuntu
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# 설치 후 재로그인 필요
```

---

## 2. 최초 환경 준비

### 2.1 프로젝트 소스 준비

```bash
# Git 저장소에서 클론 (저장소 URL은 팀 내부 확인)
git clone <저장소-URL> /app/Datablocks
cd /app/Datablocks

# 또는 이미 디렉토리가 있는 경우
cd /app/Datablocks
git pull origin main
```

### 2.2 필수 파일 확인

```bash
# 프로젝트 구조 확인
ls -la /app/Datablocks/

# 반드시 존재해야 하는 파일들
ls -la /app/Datablocks/mariadb/init/
# 확인 항목:
#   cotdl_dump.sql.data    ← DB 스키마/데이터 덤프 (git에 없으면 별도 수령)
#   cotdl_users.sql.data   ← DB 사용자 덤프 (git에 없으면 별도 수령)
#   00-load-timezone.sh
#   01-restore-dump.sh
#   02-create-users.sh
```

> **주의**: `cotdl_dump.sql.data`와 `cotdl_users.sql.data` 파일은 보안상 git에 포함되지 않을 수 있습니다. 팀 내부 경로에서 별도로 수령하여 `mariadb/init/` 디렉토리에 배치하세요.

---

## 3. `.env` 파일 설정

`.env` 파일은 민감한 정보를 포함하므로 git에 포함되지 않습니다. 샘플 파일을 복사하여 작성합니다.

```bash
# .env 파일 생성
cd /app/Datablocks
cp .env.example .env    # 샘플 파일이 있는 경우
# 또는 직접 생성
vi .env
```

### `.env` 파일 내용 (개발 환경)

```properties
# ==============================================================================
# DLM 환경 변수 - 개발 환경
# ==============================================================================

# --- Spring Boot ---
SPRING_PROFILES_ACTIVE=local

# --- MariaDB ---
MARIADB_ROOT_PASSWORD=your_root_password_here

# --- Spring Datasource ---
SPRING_DATASOURCE_URL=jdbc:mariadb://dlm-mariadb:3306/cotdl?useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Seoul&rewriteBatchedStatements=true

# --- DB 접속 계정 (v1.0.0 부터 평문 env, Jasypt 제거됨) ---
SPRING_DATASOURCE_USERNAME=cotdl
SPRING_DATASOURCE_PASSWORD=your_cotdl_password_here

# --- DLM-Privacy-AI 설정 ---
PRIVACY_AI_DB_HOST=dlm-mariadb
PRIVACY_AI_DB_PORT=3306
PRIVACY_AI_DB_NAME=cotdl
PRIVACY_AI_DB_USER=cotdl
PRIVACY_AI_DB_PASSWORD=your_cotdl_password_here
PRIVACY_AI_DLM_API_URL=http://dlm-app:8080
PRIVACY_AI_DEBUG=true
```

> **보안**: `.env` 파일의 권한을 반드시 제한하세요.
> ```bash
> chmod 600 /app/Datablocks/.env
> ```

---

## 4. 빌드 및 시작

### 4.1 최초 빌드 및 시작 (전체)

```bash
cd /app/Datablocks

# 이미지 빌드 후 모든 서비스 시작 (백그라운드)
docker compose up -d --build
```

> **참고**: 최초 빌드 시 다음 작업이 수행됩니다.
> - DLM: Gradle 의존성 다운로드 + WAR 빌드 (약 5~15분)
> - DLM-Privacy-AI: pip 패키지 설치 (약 3~10분)
> - MariaDB: DB 초기화 스크립트 실행 (타임존 로드, 덤프 복원, 사용자 생성)

### 4.2 빌드 진행 상황 모니터링

```bash
# 빌드 로그 실시간 확인 (별도 터미널에서)
docker compose logs -f

# 특정 서비스 빌드 로그만 확인
docker compose logs -f mariadb
docker compose logs -f dlm
docker compose logs -f dlm-privacy-ai
```

### 4.3 서비스 시작 순서 이해

MariaDB의 헬스체크가 통과된 후에 DLM이 시작됩니다. 최초 MariaDB 초기화(덤프 복원)는 시간이 걸릴 수 있습니다.

```
1. mariadb 시작 → 헬스체크 통과 대기 (최대 75초)
   - 00-load-timezone.sh 실행 (타임존 데이터 로드)
   - 01-restore-dump.sh 실행 (cotdl DB 스키마/데이터 복원)
   - 02-create-users.sh 실행 (cotdl 사용자 생성)
2. dlm 시작 (Spring Boot 기동, 약 30~60초)
3. dlm-privacy-ai 시작
4. portainer 시작 (독립적)
```

---

## 5. 서비스 상태 확인

### 5.1 컨테이너 실행 상태

```bash
# 모든 서비스 상태 확인
docker compose ps

# 예시 출력:
# NAME              IMAGE                         COMMAND    STATUS          PORTS
# dlm-app           datablocks-dlm                "sh -c..." Up (healthy)    0.0.0.0:8080->8080/tcp
# dlm-mariadb       mariadb:10.11                 "docker..." Up (healthy)    0.0.0.0:3306->3306/tcp
# dlm-portainer     portainer/portainer-ce:lts    "/portai..." Up            0.0.0.0:9000->9000/tcp
# dlm-privacy-ai    datablocks-dlm-privacy-ai     "uvicorn..." Up (healthy)  0.0.0.0:8000->8000/tcp
```

### 5.2 헬스체크 상태 확인

```bash
# 개별 컨테이너 헬스 상태 확인
docker inspect --format='{{.Name}} {{.State.Health.Status}}' \
  dlm-mariadb dlm-app dlm-privacy-ai

# 헬스체크 상세 이력 확인
docker inspect dlm-mariadb | grep -A 20 '"Health"'
```

### 5.3 서비스 접근 확인

```bash
# DLM 메인 애플리케이션
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/
# 200 또는 302 반환 시 정상

# DLM-Privacy-AI 헬스 엔드포인트
curl -s http://localhost:8000/health
# {"status":"ok"} 반환 시 정상

# MariaDB 접속 확인
docker exec -it dlm-mariadb mariadb -u cotdl -p'your_cotdl_password' cotdl -e "SELECT 1;"
```

---

## 6. 로그 확인

### 6.1 실시간 로그 확인

```bash
# 모든 서비스 로그 (최근 100줄 + 실시간)
docker compose logs -f --tail=100

# 특정 서비스만
docker compose logs -f dlm
docker compose logs -f dlm-privacy-ai
docker compose logs -f mariadb
docker compose logs -f portainer
```

### 6.2 과거 로그 검색

```bash
# 최근 500줄 확인
docker compose logs --tail=500 dlm

# 특정 키워드 검색
docker compose logs dlm 2>&1 | grep -i "error"
docker compose logs dlm 2>&1 | grep -i "started"
docker compose logs mariadb 2>&1 | grep -i "ready for connections"
```

### 6.3 Spring Boot 기동 완료 확인

```bash
# DLM이 정상 기동되면 아래 메시지가 로그에 출력됩니다
docker compose logs dlm 2>&1 | grep -E "Started|Tomcat initialized|in .* seconds"
# 예: Started DlmApplication in 45.234 seconds
```

### 6.4 볼륨에 저장된 로그 직접 확인

```bash
# DLM 애플리케이션 로그 볼륨 위치 확인
docker volume inspect dlm-app-logs

# 컨테이너 내부에서 로그 확인
docker exec -it dlm-app ls /app/logs/
docker exec -it dlm-app tail -f /app/logs/application.log
```

---

## 7. 서비스 중지 및 재시작

### 7.1 서비스 중지

```bash
# 모든 서비스 중지 (컨테이너 삭제, 볼륨 유지)
docker compose down

# 볼륨까지 삭제 (DB 데이터 포함 초기화 - 주의!)
docker compose down -v
```

> **경고**: `docker compose down -v` 는 MariaDB 데이터를 포함한 모든 볼륨을 삭제합니다. 개발 환경에서도 신중하게 사용하세요.

### 7.2 서비스 재시작

```bash
# 모든 서비스 재시작 (재빌드 없이)
docker compose restart

# 특정 서비스만 재시작
docker compose restart dlm
docker compose restart dlm-privacy-ai
docker compose restart mariadb
```

### 7.3 서비스 일시 중지/재개

```bash
# 특정 서비스 일시 중지 (컨테이너 유지, CPU 사용 중단)
docker compose pause dlm

# 재개
docker compose unpause dlm
```

### 7.4 서비스 중지 없이 재기동 (설정 변경 후)

```bash
# .env 파일 변경 후 적용 (컨테이너 재생성, 재빌드 없음)
docker compose up -d

# 특정 서비스만
docker compose up -d dlm
```

---

## 8. 개별 서비스 재빌드

### 8.1 DLM (Spring Boot) 재빌드

소스 코드 변경 후 재빌드가 필요할 때 사용합니다.

```bash
cd /app/Datablocks

# DLM만 재빌드 후 재시작
docker compose build dlm
docker compose up -d dlm

# 한 번에 처리 (캐시 사용)
docker compose up -d --build dlm

# 캐시 없이 완전 재빌드 (의존성 변경 시)
docker compose build --no-cache dlm
docker compose up -d dlm
```

### 8.2 DLM-Privacy-AI (FastAPI) 재빌드

```bash
# AI 서비스만 재빌드
docker compose build dlm-privacy-ai
docker compose up -d dlm-privacy-ai

# requirements.txt 변경 시 캐시 없이 재빌드
docker compose build --no-cache dlm-privacy-ai
docker compose up -d dlm-privacy-ai
```

### 8.3 MariaDB 설정 변경 (재빌드 불필요)

MariaDB는 이미 완성된 이미지를 사용하므로 재빌드 없이 설정 파일만 수정 후 재시작합니다.

```bash
# custom.cnf 수정 후 재시작
vi /app/Datablocks/mariadb/conf.d/custom.cnf
docker compose restart mariadb

# MariaDB 재시작 후 설정 적용 확인
docker exec -it dlm-mariadb mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" \
  -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';"
```

### 8.4 전체 재빌드 (완전 초기화)

```bash
# 모든 서비스 중지 및 이미지 삭제
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

## 9. Portainer 접속

Portainer는 Docker 컨테이너를 웹 UI로 관리할 수 있는 도구입니다.

### 9.1 최초 접속 및 관리자 계정 설정

1. 브라우저에서 `http://localhost:9000` 접속
2. 최초 접속 시 관리자 비밀번호 설정 화면 표시
3. 관리자 계정(admin) 및 비밀번호 설정 (8자 이상)
4. "Create user" 클릭
5. "Get Started" → "local" 환경 선택

> **주의**: Portainer는 최초 접속 후 5분 이내에 관리자 계정을 설정하지 않으면 보안을 위해 초기화됩니다. 초기화된 경우 컨테이너를 재시작하세요.
> ```bash
> docker compose restart portainer
> ```

### 9.2 Portainer 주요 기능

| 기능 | 위치 | 설명 |
|------|------|------|
| 컨테이너 목록 | Containers | 실행 중인 컨테이너 확인 및 관리 |
| 로그 확인 | Containers → [컨테이너] → Logs | 실시간 로그 스트리밍 |
| 콘솔 접속 | Containers → [컨테이너] → Console | 컨테이너 내부 셸 접근 |
| 이미지 관리 | Images | 빌드된 이미지 확인/삭제 |
| 볼륨 관리 | Volumes | 데이터 볼륨 확인 |
| 리소스 통계 | Containers → [컨테이너] → Stats | CPU/메모리 사용량 실시간 확인 |

### 9.3 Portainer 자격증명 분실 시

```bash
# Portainer 데이터 볼륨 삭제 후 재시작하면 초기화됩니다
docker compose stop portainer
docker volume rm dlm-portainer-data
docker compose up -d portainer
```

---

## 부록: 유용한 단축 명령어 모음

```bash
# 서비스 전체 상태 한눈에 보기
docker compose ps && docker stats --no-stream

# 특정 컨테이너에 셸 접속
docker exec -it dlm-app /bin/sh
docker exec -it dlm-privacy-ai /bin/sh
docker exec -it dlm-mariadb /bin/bash
docker exec -it dlm-portainer /bin/sh

# MariaDB 클라이언트 접속
docker exec -it dlm-mariadb mariadb -u cotdl -p cotdl

# 사용 중인 포트 확인 (충돌 방지)
ss -tlnp | grep -E '8080|8000|3306|9000'
# 또는
lsof -i :8080 -i :8000 -i :3306 -i :9000

# Docker 리소스 사용량 확인
docker system df
```
