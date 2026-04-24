# Docker 핵심 개념 가이드

## 목차
1. [Docker 컨테이너란?](#1-docker-컨테이너란)
2. [컨테이너 내부 파일을 직접 수정하면 안 되는 이유](#2-컨테이너-내부-파일을-직접-수정하면-안-되는-이유)
3. [올바른 수정 방법 3가지](#3-올바른-수정-방법-3가지)
4. [볼륨 마운트 이해하기](#4-볼륨-마운트-이해하기)
5. [설정 파일 외부화 (Bind Mount)](#5-설정-파일-외부화-bind-mount)
6. [DLM 프로젝트 볼륨 구성](#6-dlm-프로젝트-볼륨-구성)

---

## 1. Docker 컨테이너란?

### 1.1 한 줄 요약

> **컨테이너 = 격리된 미니 OS**. 각 컨테이너는 자체 파일 시스템, 프로세스, 네트워크를 가진 독립된 실행 환경입니다.

### 1.2 구조 이해

```
┌─────────────────────────────────────────────────────┐
│                   호스트 서버 (Linux)                  │
│                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │  dlm-app    │  │ dlm-mariadb │  │ privacy-ai  │  │
│  │             │  │             │  │             │  │
│  │ 자체 파일   │  │ 자체 파일   │  │ 자체 파일   │  │
│  │ 자체 프로세스│  │ 자체 프로세스│  │ 자체 프로세스│  │
│  │ 자체 네트워크│  │ 자체 네트워크│  │ 자체 네트워크│  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│                                                       │
│              공유: 호스트 OS 커널 (Linux)              │
└─────────────────────────────────────────────────────┘
```

### 1.3 VM(가상머신)과의 차이

| 항목 | 가상머신 (VM) | Docker 컨테이너 |
|------|-------------|----------------|
| 크기 | 수 GB (OS 전체 포함) | 수십~수백 MB |
| 시작 시간 | 수 분 | 수 초 |
| OS 커널 | 각자 별도 커널 | 호스트 커널 공유 |
| 격리 수준 | 완전 격리 (하드웨어 레벨) | 프로세스 레벨 격리 |
| 리소스 | 고정 할당 | 필요한 만큼 사용 |

**핵심**: 컨테이너는 VM처럼 완전히 독립된 환경을 제공하지만, OS 커널을 공유하므로 훨씬 가볍고 빠릅니다.

### 1.4 이미지와 컨테이너

```
Dockerfile  →  (docker build)  →  이미지  →  (docker run)  →  컨테이너
  (설계도)                        (틀/템플릿)                  (실행 인스턴스)
```

| 개념 | 비유 | 설명 |
|------|------|------|
| Dockerfile | 레시피 | 이미지를 만드는 명령어 모음 |
| 이미지 | 붕어빵 틀 | 읽기 전용 템플릿, 여러 컨테이너를 생성 가능 |
| 컨테이너 | 붕어빵 | 이미지로부터 생성된 실행 인스턴스 |

---

## 2. 컨테이너 내부 파일을 직접 수정하면 안 되는 이유

### 2.1 변경이 소실되는 경우

컨테이너 내부에서 파일을 수정(`docker exec`로 접속해서 vi 등으로 편집)하면, 다음 상황에서 **모든 변경이 사라집니다**:

| 상황 | 내부 수정 보존? | 발생 빈도 |
|------|:--:|------|
| `docker compose restart` | O (유지) | - |
| `docker compose down` + `up` | **X (소실)** | 자주 |
| `docker compose up --build` | **X (소실)** | 코드 변경 시 매번 |
| 서버 재부팅 후 자동 시작 | O (유지) | - |
| 이미지 업데이트 후 재생성 | **X (소실)** | 업그레이드 시 |

### 2.2 왜 소실되는가?

```
이미지 (읽기 전용 레이어)
  └── 컨테이너 레이어 (읽기/쓰기) ← docker exec로 수정한 내용은 여기에 저장
         ↑
      컨테이너 삭제 시 이 레이어도 함께 삭제됨
```

`docker compose up --build`는 새 이미지를 빌드하고, 기존 컨테이너를 삭제한 뒤 새 컨테이너를 생성합니다. 이 과정에서 컨테이너 레이어(수정한 내용)는 사라집니다.

### 2.3 결론

> **컨테이너 내부 직접 수정은 임시 디버깅 용도로만 사용하고, 영구적인 변경은 반드시 아래 3가지 방법 중 하나를 사용하세요.**

---

## 3. 올바른 수정 방법 3가지

### 방법 1: 소스 수정 후 이미지 재빌드 (권장)

**적용 대상**: Java 소스 코드, 설정 파일, 의존성 변경 등

```bash
# 1. 호스트에서 소스 코드 수정
vi /app/Datablocks/DLM/src/main/resources/application.properties

# 2. 이미지 재빌드 + 컨테이너 재생성
cd /app/Datablocks
docker compose up -d --build dlm

# 3. 로그로 정상 기동 확인
docker compose logs -f --tail=50 dlm
```

**장점**: 변경 이력이 Git에 남고, 팀원 간 공유 가능, 재현 가능
**단점**: 빌드 시간 소요 (Gradle 캐시 활용 시 2~3분)

---

### 방법 2: 환경변수 오버라이드

**적용 대상**: DB 접속 정보, 포트, Spring 프로필 등 `.env`로 제어 가능한 항목

```bash
# .env 파일 수정
vi /app/Datablocks/.env
```

```properties
# 예: Spring 프로필 변경
SPRING_PROFILES_ACTIVE=prod

# 예: JVM 옵션 변경
JAVA_OPTS=-Xms4g -Xmx12g -XX:+UseG1GC

# 예: DB 접속 정보 변경
SPRING_DATASOURCE_URL=jdbc:mariadb://new-db-host:3306/cotdl
```

```bash
# 환경변수 변경 후 재시작 (재빌드 불필요)
docker compose up -d
```

**장점**: 재빌드 없이 즉시 반영, 환경별(개발/운영) 설정 분리 용이
**단점**: 애플리케이션이 해당 환경변수를 지원해야 함

---

### 방법 3: 볼륨 마운트 (파일 교체)

**적용 대상**: 설정 파일(logback, nginx.conf 등)을 재빌드 없이 교체하고 싶을 때

```yaml
# docker-compose.yml (또는 override 파일)
services:
  dlm:
    volumes:
      - ./config/logback-prod.xml:/app/config/logback-prod.xml:ro
```

```bash
# 호스트의 파일을 수정하면 컨테이너에 즉시 반영 (재시작 필요할 수 있음)
vi /app/Datablocks/config/logback-prod.xml
docker compose restart dlm
```

**장점**: 재빌드 불필요, 파일 단위로 교체 가능
**단점**: docker-compose.yml에 마운트 설정 추가 필요

---

### 방법별 비교 요약

| 항목 | 재빌드 | 환경변수 | 볼륨 마운트 |
|------|:------:|:-------:|:---------:|
| 재빌드 필요 | O | X | X |
| Git 이력 관리 | O | O (.env) | O |
| 적용 속도 | 느림 (2~3분) | 즉시 | 즉시 |
| 적용 범위 | 모든 파일 | 환경변수만 | 특정 파일 |
| 주 사용 시나리오 | 코드 변경 | 환경별 설정 | 운영 중 설정 교체 |

---

## 4. 볼륨 마운트 이해하기

### 4.1 볼륨이 필요한 이유

컨테이너는 삭제되면 내부 데이터가 모두 사라집니다. **영구 보존이 필요한 데이터**는 볼륨에 저장합니다.

```
컨테이너 삭제 시:
  컨테이너 내부 파일  → 소실
  볼륨에 저장된 파일  → 보존
```

### 4.2 Named Volume vs Bind Mount

| 유형 | Named Volume | Bind Mount |
|------|-------------|------------|
| 선언 | `volumes:` 섹션에 이름 선언 | 호스트 경로 직접 지정 |
| 예시 | `dlm_logs:/app/logs` | `./config/logback.xml:/app/config/logback.xml` |
| 저장 위치 | Docker가 관리 (`/var/lib/docker/volumes/`) | 지정한 호스트 경로 |
| 용도 | DB 데이터, 로그 등 영구 저장 | 설정 파일 교체, 개발 시 소스 동기화 |
| 접근성 | `docker volume inspect`로 경로 확인 | 호스트에서 직접 접근 가능 |

### 4.3 DLM 프로젝트의 예시

```yaml
# docker-compose.yml
services:
  dlm:
    volumes:
      - dlm_logs:/app/logs        # Named Volume: 로그 영구 저장
      - dlm_upload:/app/upload    # Named Volume: 업로드 파일 영구 저장

volumes:
  dlm_logs:
    name: dlm-app-logs            # Docker에서 관리하는 볼륨 이름
  dlm_upload:
    name: dlm-app-upload
```

### 4.4 자동 생성과 권한

- **볼륨 자동 생성**: `docker compose up` 시 선언된 볼륨이 없으면 Docker가 자동으로 생성합니다
- **디렉토리 자동 생성**: 컨테이너 내부 마운트 경로가 없으면 Docker가 자동으로 생성합니다
- **권한**: Dockerfile에서 `RUN mkdir -p /app/logs && chown dlm:dlm /app`처럼 미리 권한을 설정해두면, 볼륨 마운트 시에도 해당 권한이 유지됩니다

```dockerfile
# DLM Dockerfile 예시
RUN groupadd -r dlm && useradd -r -g dlm -d /app -s /sbin/nologin dlm
RUN mkdir -p /app/logs /app/upload && chown -R dlm:dlm /app
USER dlm
```

### 4.5 볼륨 데이터 확인

```bash
# Named Volume 목록 확인
docker volume ls | grep dlm

# 볼륨 상세 정보 (호스트 실제 경로 확인)
docker volume inspect dlm-app-logs

# 볼륨 내 파일 직접 확인 (root 권한 필요)
sudo ls -la $(docker volume inspect dlm-app-logs --format '{{.Mountpoint}}')
```

---

## 5. 설정 파일 외부화 (Bind Mount)

### 5.1 시나리오

운영 환경에서 DLM을 배포한 후, **재빌드 없이** `logback-prod.xml`의 로그 레벨을 변경하고 싶은 경우.

### 5.2 설정 방법

**Step 1**: 호스트에 설정 파일 디렉토리 생성

```bash
mkdir -p /app/Datablocks/config
cp /app/Datablocks/DLM/src/main/resources/logback-prod.xml /app/Datablocks/config/
```

**Step 2**: `docker-compose.prod.yml`에 Bind Mount 추가

```yaml
# docker-compose.prod.yml
services:
  dlm:
    volumes:
      - ./config/logback-prod.xml:/app/config/logback-prod.xml:ro
    environment:
      - LOGGING_CONFIG=/app/config/logback-prod.xml
```

> `:ro`는 read-only 마운트로, 컨테이너 내부에서 실수로 파일을 수정하는 것을 방지합니다.

**Step 3**: 반영

```bash
cd /app/Datablocks

# 재빌드 없이 설정만 반영
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d dlm
```

### 5.3 로그 레벨 변경 예시

```bash
# 호스트에서 logback-prod.xml 수정
vi /app/Datablocks/config/logback-prod.xml
```

```xml
<!-- 변경 전: WARN 레벨 -->
<root level="WARN">
    <appender-ref ref="FILE"/>
</root>

<!-- 변경 후: INFO 레벨 (디버깅 필요 시) -->
<root level="INFO">
    <appender-ref ref="FILE"/>
</root>
```

```bash
# DLM 재시작 (재빌드 아님, 수 초 소요)
docker compose restart dlm
```

> **참고**: logback의 `<configuration scan="true">` 설정이 되어 있으면 재시작 없이도 변경이 자동 감지됩니다 (기본 60초 주기).

---

## 6. DLM 프로젝트 볼륨 구성

### 6.1 현재 볼륨 매핑 요약

| 서비스 | 컨테이너 경로 | 볼륨 | 용도 |
|--------|-------------|------|------|
| dlm-app | /app/logs | dlm-app-logs | 애플리케이션 로그 (Logback) |
| dlm-app | /app/upload | dlm-app-upload | 파일 업로드 저장소 |
| dlm-mariadb | /var/lib/mysql | dlm-mariadb-data | DB 데이터 |
| dlm-mariadb | /var/log/mysql | dlm-mariadb-logs | DB 로그 (슬로우 쿼리 등) |
| dlm-privacy-ai | /app/logs | dlm-privacy-ai-logs | AI 서비스 로그 |
| dlm-privacy-ai | /app/models | dlm-privacy-ai-models | AI 모델 파일 |
| dlm-portainer | /data | dlm-portainer-data | Portainer 설정 |

### 6.2 Bind Mount (호스트 파일 직접 마운트)

| 호스트 경로 | 컨테이너 경로 | 서비스 | 용도 |
|-----------|------------|-------|------|
| ./mariadb/conf.d/custom.cnf | /etc/mysql/conf.d/custom.cnf | mariadb | MariaDB 설정 |
| ./mariadb/init/ | /docker-entrypoint-initdb.d/ | mariadb | DB 초기화 스크립트 |
| /var/run/docker.sock | /var/run/docker.sock | portainer | Docker API 접근 |

### 6.3 로그 경로 정리

DLM 애플리케이션의 모든 Logback 설정 파일(`logback-local.xml`, `logback-prod.xml`, `logback-spring.xml`)은 `/app/logs` 디렉토리에 로그를 기록합니다. 이 경로는 Named Volume(`dlm-app-logs`)으로 마운트되어 컨테이너 재시작/재빌드 후에도 로그가 보존됩니다.

```
호스트                              컨테이너(dlm-app)
/var/lib/docker/volumes/            /app/logs/
  dlm-app-logs/_data/       ←→       app.log
    app.log                           app.2025-09-26.0.gz
    app.2025-09-26.0.gz               ...
```
