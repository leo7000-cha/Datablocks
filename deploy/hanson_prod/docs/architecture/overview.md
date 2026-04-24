# DLM 프로젝트 개요 및 아키텍처

## 목차
1. [프로젝트 소개](#1-프로젝트-소개)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [서비스 구성표](#3-서비스-구성표)
4. [포트 매핑](#4-포트-매핑)
5. [네트워크 토폴로지](#5-네트워크-토폴로지)
6. [볼륨 구성](#6-볼륨-구성)
7. [환경 구성 파일 목록](#7-환경-구성-파일-목록)
8. [문서 목록](#8-문서-목록)

---

## 1. 프로젝트 소개

**DLM (Data Lifecycle Management)** 은 개인정보 분리보관 및 파기 솔루션입니다. Spring Boot 기반의 메인 애플리케이션과 FastAPI 기반의 AI 서비스로 구성되며, MariaDB를 데이터베이스로 사용합니다.

| 항목 | 내용 |
|------|------|
| 메인 애플리케이션 | Spring Boot 3.3 / Java 21 / Gradle 8.9 / WAR 패키징 |
| AI 서비스 | FastAPI / Python 3.11 |
| 데이터베이스 | MariaDB 10.11 |
| 관리 도구 | Portainer CE (Docker 관리 UI) |
| 컨테이너 런타임 | Docker + Docker Compose |

---

## 2. 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                         호스트 서버                              │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    dlm-network (bridge)                  │   │
│  │                                                          │   │
│  │  ┌──────────────┐     ┌──────────────────────────────┐  │   │
│  │  │  dlm-mariadb │     │         dlm-app              │  │   │
│  │  │  MariaDB10.11│◄────│  Spring Boot 3.3 / Java 21   │  │   │
│  │  │  Port: 3306  │     │       Port: 8080             │  │   │
│  │  └──────┬───────┘     └──────────────┬───────────────┘  │   │
│  │         │                            │                   │   │
│  │         │             ┌──────────────▼───────────────┐  │   │
│  │         └─────────────│       dlm-privacy-ai         │  │   │
│  │                       │   FastAPI / Python 3.11      │  │   │
│  │                       │       Port: 8000             │  │   │
│  │                       └──────────────────────────────┘  │   │
│  │                                                          │   │
│  │  ┌──────────────────────────────────────────────────┐   │   │
│  │  │              dlm-portainer                       │   │   │
│  │  │         Portainer CE (Docker UI)                 │   │   │
│  │  │              Port: 9000                          │   │   │
│  │  └──────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  외부 접근:                                                      │
│    :8080 → DLM 메인 애플리케이션                                 │
│    :8000 → DLM Privacy AI API                                    │
│    :3306 → MariaDB (개발 환경, 운영 환경은 방화벽으로 차단)      │
│    :9000 → Portainer Docker 관리 UI                              │
└─────────────────────────────────────────────────────────────────┘
```

### 서비스 간 통신 흐름

```
사용자 브라우저
      │
      ▼ HTTP :8080
┌─────────────┐
│   dlm-app   │──────────────────────────► dlm-mariadb:3306
│ (Spring Boot)│                               (DB 조회/저장)
└──────┬──────┘
       │ HTTP :8000
       ▼
┌────────────────┐
│ dlm-privacy-ai │──────────────────────► dlm-mariadb:3306
│   (FastAPI)    │                           (AI 결과 저장)
└────────────────┘

관리자
  │
  ▼ HTTP :9000
┌─────────────┐
│ dlm-portainer│── /var/run/docker.sock ──► Docker Daemon
│  (Portainer) │                           (컨테이너 관리)
└─────────────┘
```

---

## 3. 서비스 구성표

| 서비스명 | 컨테이너명 | 이미지/빌드 | 역할 | 재시작 정책 |
|---------|-----------|------------|------|------------|
| mariadb | dlm-mariadb | mariadb:10.11 | 관계형 데이터베이스 | unless-stopped |
| dlm | dlm-app | ./DLM/Dockerfile (빌드) | 메인 웹 애플리케이션 | unless-stopped |
| dlm-privacy-ai | dlm-privacy-ai | ./DLM-Privacy-AI/Dockerfile (빌드) | AI 개인정보 분석 서비스 | unless-stopped |
| portainer | dlm-portainer | portainer/portainer-ce:lts | Docker 관리 UI | unless-stopped |

### 서비스 의존 관계

```
mariadb (healthy)
    ├── dlm (depends_on: mariadb healthy)
    │       └── dlm-privacy-ai (depends_on: mariadb healthy + dlm started)
    └── dlm-privacy-ai

portainer (독립 실행, Docker 소켓 마운트)
```

> **중요**: `dlm`은 MariaDB가 정상(healthy) 상태일 때만 시작됩니다. `dlm-privacy-ai`는 MariaDB가 healthy이고 dlm이 시작된 후 구동됩니다.

---

## 4. 포트 매핑

| 호스트 포트 | 컨테이너 포트 | 서비스 | 프로토콜 | 용도 |
|-----------|------------|-------|---------|------|
| 8080 | 8080 | dlm-app | TCP/HTTP | DLM 웹 애플리케이션 |
| 8000 | 8000 | dlm-privacy-ai | TCP/HTTP | FastAPI AI 서비스 |
| 3306 | 3306 | dlm-mariadb | TCP/MySQL | 데이터베이스 |
| 9000 | 9000 | dlm-portainer | TCP/HTTP | Portainer 관리 UI |

> **보안 주의**: 운영 환경에서 3306 포트는 방화벽(ufw/firewalld)으로 외부 접근을 차단하고, 컨테이너 네트워크 내부에서만 사용해야 합니다.

---

## 5. 네트워크 토폴로지

### Docker 네트워크 설정

```
네트워크 이름: dlm-network
드라이버:     bridge
```

컨테이너 간 통신 시 서비스명을 DNS 호스트명으로 사용합니다.

| 통신 경로 | 내부 주소 |
|---------|---------|
| DLM → MariaDB | `dlm-mariadb:3306` |
| DLM-Privacy-AI → MariaDB | `dlm-mariadb:3306` |
| DLM-Privacy-AI → DLM | `dlm-app:8080` |
| Portainer → Docker Daemon | `/var/run/docker.sock` |

### .env 파일 내 DB 연결 URL 예시

```properties
SPRING_DATASOURCE_URL=jdbc:mariadb://dlm-mariadb:3306/cotdl?...
PRIVACY_AI_DB_HOST=dlm-mariadb
PRIVACY_AI_DLM_API_URL=http://dlm-app:8080
```

---

## 6. 볼륨 구성

| 볼륨명 | Docker 볼륨 이름 | 마운트 경로 | 용도 |
|-------|----------------|-----------|------|
| mariadb_data | dlm-mariadb-data | /var/lib/mysql | MariaDB 데이터 |
| mariadb_logs | dlm-mariadb-logs | /var/log/mysql | MariaDB 로그 |
| dlm_logs | dlm-app-logs | /app/logs | DLM 애플리케이션 로그 |
| dlm_upload | dlm-app-upload | /app/upload | DLM 파일 업로드 |
| privacy_ai_logs | dlm-privacy-ai-logs | /app/logs | AI 서비스 로그 |
| privacy_ai_models | dlm-privacy-ai-models | /app/models | AI 모델 파일 |
| portainer_data | dlm-portainer-data | /data | Portainer 설정 |

### 바인드 마운트 (호스트 경로 직접 마운트)

| 호스트 경로 | 컨테이너 경로 | 서비스 | 용도 |
|-----------|------------|-------|------|
| ./mariadb/conf.d/custom.cnf | /etc/mysql/conf.d/custom.cnf | mariadb (dev) | MariaDB 설정 |
| ./mariadb/conf.d/custom-prod.cnf | /etc/mysql/conf.d/custom.cnf | mariadb (prod) | MariaDB 설정 (운영) |
| ./mariadb/init/ | /docker-entrypoint-initdb.d/ | mariadb | DB 초기화 스크립트 |
| /var/run/docker.sock | /var/run/docker.sock | portainer | Docker API 접근 |

> **참고**: DLM의 모든 Logback 설정은 `/app/logs` 경로를 사용하며, Named Volume(`dlm-app-logs`)으로 마운트되어 영구 보존됩니다.

---

## 7. 환경 구성 파일 목록

```
/app/Datablocks/
├── .env                          # 환경변수 파일 (git에 포함 금지!)
├── docker-compose.yml            # 기본 (개발) Compose 파일
├── docker-compose.prod.yml       # 운영 환경 오버라이드 파일
├── DLM/
│   ├── Dockerfile                # DLM Spring Boot 빌드
│   └── src/                      # Java 소스 코드
├── DLM-Privacy-AI/
│   ├── Dockerfile                # FastAPI 빌드
│   ├── requirements.txt          # Python 패키지 목록
│   └── app/                      # Python 소스 코드
└── mariadb/
    ├── conf.d/
    │   ├── custom.cnf            # MariaDB 개발 설정
    │   └── custom-prod.cnf       # MariaDB 운영 설정
    └── init/
        ├── 00-load-timezone.sh   # 타임존 데이터 로드
        ├── 01-restore-dump.sh    # DB 덤프 복원
        ├── 02-create-users.sh    # DB 사용자 생성
        ├── cotdl_dump.sql.data   # DB 스키마/데이터 덤프
        └── cotdl_users.sql.data  # DB 사용자 계정 덤프
```

---

## 8. 문서 목록

| 파일 | 내용 |
|------|------|
| [00-overview.md](./00-overview.md) | 프로젝트 개요 및 아키텍처 (현재 문서) |
| [01-dev-setup.md](./01-dev-setup.md) | 개발 환경 설정 가이드 |
| [02-prod-deploy.md](./02-prod-deploy.md) | 운영 환경 배포 가이드 |
| [03-operations.md](./03-operations.md) | 일상 운영 가이드 |
| [04-troubleshooting.md](./04-troubleshooting.md) | 문제 해결 가이드 |
| [05-resource-allocation.md](./05-resource-allocation.md) | 리소스 설정 가이드 |
| [06-docker-concepts.md](./06-docker-concepts.md) | Docker 핵심 개념 가이드 |
| [07-pii-discovery-flow.md](./07-pii-discovery-flow.md) | PII 개인정보 자동탐지 엔진 흐름 |
