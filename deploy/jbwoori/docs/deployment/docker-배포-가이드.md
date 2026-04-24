# DLM Docker 배포 가이드

> Docker 경험이 전혀 없는 분도 따라할 수 있도록 작성한 가이드입니다.
> 모든 명령어는 리눅스(CentOS/Ubuntu) 서버 기준입니다.

---

## 목차

1. [Docker란?](#1-docker란)
2. [Docker Compose란?](#2-docker-compose란)
3. [우리 프로젝트 구조](#3-우리-프로젝트-구조)
4. [필수 설치](#4-필수-설치)
5. [개발환경 실행 방법](#5-개발환경-실행-방법)
6. [고객사 배포 방법](#6-고객사-배포-방법)
7. [자주 쓰는 Docker 명령어](#7-자주-쓰는-docker-명령어)
8. [트러블슈팅](#8-트러블슈팅)
9. [.env 파일 설명](#9-env-파일-설명)

---

## 1. Docker란?

### 한 줄 요약

> **Docker = 프로그램을 "상자"에 넣어서 어디서든 똑같이 실행되게 하는 도구**

### 비유로 이해하기

#### 컨테이너(Container) = 이사 박스

```
일반적인 소프트웨어 설치                Docker 사용
========================              ========================

"이 프로그램 설치하려면              "Docker 컨테이너 하나만
 Java 21도 깔아야 하고...             실행하면 끝!"
 설정 파일도 바꿔야 하고...
 라이브러리 버전도 맞춰야 하고...
 OS마다 다르고..."

     (  ;_;)                             \(^o^)/
```

이사할 때를 생각해보세요.

- **Docker 없이** = 물건을 하나하나 들고 옮기는 것. 깨지기도 하고, 빠뜨리기도 하고, 새 집에서 배치가 안 맞기도 함.
- **Docker 사용** = 방 전체를 박스에 넣어서 옮기는 것. 박스만 내려놓으면 원래대로 완성!

이 "박스"가 바로 **컨테이너(Container)** 입니다.

#### 이미지(Image) = 레시피

```
  +-----------------+          +-----------------+
  |    이미지       |          |   컨테이너      |
  |   (레시피)      |   실행   |   (실제 요리)   |
  |                 |  ----->  |                 |
  |  - Java 21     |          |  실제 돌아가는  |
  |  - Spring Boot |          |   프로그램      |
  |  - DLM 소스코드 |          |                 |
  +-----------------+          +-----------------+

  하나의 레시피로                같은 요리를
  (이미지 1개)                  여러 개 만들 수 있음
                                (컨테이너 여러 개)
```

- **이미지(Image)** = 요리 레시피. "어떤 재료(Java, Python 등)를 넣고, 어떤 순서로 조리하는지" 적혀 있음.
- **컨테이너(Container)** = 레시피대로 만든 실제 요리. 진짜로 실행되고 있는 프로그램.

정리하면:

| 개념 | 비유 | 설명 |
|------|------|------|
| **이미지** | 레시피, 설계도 | 프로그램 실행에 필요한 모든 것을 담은 "틀" |
| **컨테이너** | 요리, 완성된 건물 | 이미지를 기반으로 실제 실행 중인 프로그램 |
| **Dockerfile** | 레시피를 적는 종이 | 이미지를 만드는 방법이 적힌 파일 |
| **볼륨(Volume)** | 냉장고 | 컨테이너가 꺼져도 데이터가 남아있는 저장소 |

#### 왜 Docker를 쓰나요?

```
개발자 PC에서:  "내 컴퓨터에선 잘 되는데...?"
테스트 서버에서: "여기서는 왜 안 되지...?"
고객사 서버에서: "Java 버전이 달라서 안 됩니다"

         |
         | Docker 도입!
         v

개발자 PC에서:  "Docker로 실행!" --> 됨!
테스트 서버에서: "Docker로 실행!" --> 됨!
고객사 서버에서: "Docker로 실행!" --> 됨!
```

Docker가 설치된 곳이면 **어디서든 동일하게** 실행됩니다.

---

## 2. Docker Compose란?

### 한 줄 요약

> **Docker Compose = 여러 개의 컨테이너를 한 번에 관리하는 도구**

### 비유로 이해하기

```
Docker만 사용하면:
===================

  $ docker run mariadb ...     (1) DB 먼저 실행
  $ docker run dlm ...         (2) DLM 실행
  $ docker run privacy-ai ...  (3) AI 실행
  $ docker run portainer ...   (4) 모니터링 실행

  --> 명령어를 4번 입력해야 하고,
      순서도 지켜야 하고,
      설정도 매번 입력해야 합니다.


Docker Compose를 사용하면:
==========================

  $ docker compose up -d       (끝!)

  --> 명령어 1번이면 4개 전부 실행.
      순서도 자동, 설정도 파일에 저장되어 있음.
```

#### docker-compose.yml = 식당의 주문서

```
  docker-compose.yml 파일 = "오늘의 풀코스 메뉴"

  +-------------------------------------------------+
  |  주문서 (docker-compose.yml)                     |
  |                                                  |
  |  1번 테이블: MariaDB        (데이터베이스)        |
  |  2번 테이블: DLM            (메인 웹 애플리케이션) |
  |  3번 테이블: DLM-Privacy-AI (AI 엔진)            |
  |  4번 테이블: Portainer      (관리 도구)           |
  |                                                  |
  |  [주방에 전달] = docker compose up -d             |
  +-------------------------------------------------+
```

식당에서 코스 메뉴를 주문하면 주방에서 알아서 순서대로 요리를 내오듯이,
`docker-compose.yml` 파일에 적어두면 Docker가 알아서 순서대로 실행합니다.

---

## 3. 우리 프로젝트 구조

### 전체 구성도 (개발환경)

```
  +-----------------------------------------------------------------+
  |                        서버 (호스트 머신)                         |
  |                                                                  |
  |   +-----------------------------------------------------------+  |
  |   |              Docker Engine                                 |  |
  |   |                                                            |  |
  |   |   +-------------+    +-------------+    +---------------+  |  |
  |   |   |  MariaDB    |    |    DLM      |    | DLM-Privacy   |  |  |
  |   |   |  10.11      |    | Spring Boot |    |    -AI        |  |  |
  |   |   |             |    |  Java 21    |    |  FastAPI      |  |  |
  |   |   |  Port 3306  |    |  Port 8080  |    |  Port 8000    |  |  |
  |   |   +------+------+    +------+------+    +-------+-------+  |  |
  |   |          |                  |                    |          |  |
  |   |          +------------------+--------------------+          |  |
  |   |                     dlm-network                            |  |
  |   |                  (내부 전용 네트워크)                        |  |
  |   |                                                            |  |
  |   |   +---------------+                                        |  |
  |   |   | Portainer     |                                        |  |
  |   |   | (관리 UI)     |                                        |  |
  |   |   | Port 9000     |                                        |  |
  |   |   +---------------+                                        |  |
  |   |                                                            |  |
  |   +-----------------------------------------------------------+  |
  |                                                                  |
  +-----------------------------------------------------------------+

  외부 접속:
    - 웹 브라우저 --> http://서버IP:8080  --> DLM (메인 화면)
    - 웹 브라우저 --> http://서버IP:9000  --> Portainer (관리 화면)
```

### 컨테이너별 역할

| 컨테이너 | 포트 | 역할 | 비유 |
|-----------|------|------|------|
| `dlm-mariadb` | 3306 | 데이터베이스 | 도서관 (데이터 저장소) |
| `dlm-app` | 8080 | 메인 웹 애플리케이션 | 프론트 데스크 (사용자 요청 처리) |
| `dlm-privacy-ai` | 8000 | AI 개인정보 탐지 | 보안 전문가 (개인정보 분석) |
| `dlm-portainer` | 9000 | Docker 관리 UI | CCTV 모니터링룸 (상태 확인) |

### 컨테이너 간 통신 흐름

```
  사용자 (웹 브라우저)
       |
       | http://서버IP:8080
       v
  +----+--------+     "개인정보 분석해줘"     +------------------+
  |   DLM       | --------------------------> | DLM-Privacy-AI   |
  | (Spring Boot)|    http://dlm-privacy-     | (FastAPI)        |
  |  :8080      | <----- ai:8000 ----------- |  :8000           |
  +----+--------+     "분석 결과야"           +--------+---------+
       |                                               |
       | DB 조회/저장                                   | DB 조회
       v                                               v
  +----+--------+                             +--------+---------+
  |  MariaDB    | <------ 같은 DB ----------> |     (동일 DB)     |
  |  :3306      |                             |                  |
  +-------------+                             +------------------+
```

### 파일 구조

```
/app/Datablocks/                    <-- 프로젝트 루트
|
+-- docker-compose.yml              <-- 개발환경 (4개 컨테이너)
+-- docker-compose.customer.yml     <-- 고객사 배포 (2개 컨테이너)
+-- .env                            <-- 개발환경 환경변수
+-- .env.customer                   <-- 고객사 환경변수
|
+-- DLM/                            <-- Spring Boot 소스코드
|   +-- Dockerfile                  <-- DLM 이미지 빌드 설정
|   +-- src/                        <-- Java 소스
|   +-- build.gradle                <-- 빌드 설정
|
+-- DLM-Privacy-AI/                 <-- FastAPI 소스코드
|   +-- Dockerfile                  <-- Privacy-AI 이미지 빌드 설정
|   +-- app/                        <-- Python 소스
|   +-- requirements.txt            <-- Python 의존성
|
+-- mariadb/                        <-- MariaDB 설정
|   +-- conf.d/custom.cnf           <-- DB 설정 파일
|   +-- init/                       <-- 초기화 SQL 스크립트
|
+-- docs/                           <-- 문서
```

### 고객사 배포 구성도

고객사에서는 MariaDB를 이미 보유하고 있으므로, Docker로는 DLM과 Privacy-AI만 실행합니다.

```
  +----------------------------------------------+
  |          고객사 서버 (Docker)                  |
  |                                               |
  |   +-------------+    +------------------+     |
  |   |    DLM      |    | DLM-Privacy-AI   |     |
  |   | (Spring Boot)|    | (FastAPI)        |     |
  |   |  Port 8080  |    |  Port 8000       |     |
  |   +------+------+    +--------+---------+     |
  |          |                     |               |
  +----------+---------------------+---------------+
             |                     |
             |   네트워크 (TCP)     |
             v                     v
  +----------+---------------------+---------------+
  |             고객사 기존 DB 서버                  |
  |               MariaDB                          |
  |            192.168.x.x:3306                    |
  +------------------------------------------------+
```

---

## 4. 필수 설치

### 4-1. Docker Engine 설치

#### CentOS / RHEL 7, 8, 9

```bash
# 1. 기존 Docker 제거 (혹시 이전 버전이 있다면)
sudo yum remove -y docker docker-client docker-client-latest \
    docker-common docker-latest docker-latest-logrotate \
    docker-logrotate docker-engine

# 2. 필요한 패키지 설치
sudo yum install -y yum-utils

# 3. Docker 공식 저장소 추가
sudo yum-config-manager --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# 4. Docker 설치
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 5. Docker 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# 6. 현재 사용자를 docker 그룹에 추가 (sudo 없이 docker 명령 가능)
sudo usermod -aG docker $USER

# 7. 그룹 변경 적용 (로그아웃 후 재접속하거나 아래 명령 실행)
newgrp docker

# 8. 설치 확인
docker --version
docker compose version
```

#### Ubuntu 20.04 / 22.04 / 24.04

```bash
# 1. 기존 Docker 제거
sudo apt-get remove -y docker docker-engine docker.io containerd runc

# 2. 필요한 패키지 설치
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# 3. Docker 공식 GPG 키 추가
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Docker 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Docker 설치
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 6. Docker 시작 및 자동 시작 설정
sudo systemctl start docker
sudo systemctl enable docker

# 7. 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
newgrp docker

# 8. 설치 확인
docker --version
docker compose version
```

### 4-2. 설치 확인

```bash
# Docker가 정상 작동하는지 테스트
docker run hello-world
```

아래와 비슷한 메시지가 나오면 성공입니다:

```
Hello from Docker!
This message shows that your installation appears to be working correctly.
```

> **주의**: `docker compose version` 에서 버전이 출력되어야 합니다.
> `docker-compose`(하이픈)가 아닌 `docker compose`(공백)를 사용합니다.
> Docker Compose V2는 Docker Engine에 플러그인으로 포함되어 있어 별도 설치가 필요 없습니다.

---

## 5. 개발환경 실행 방법

### 5-1. 사전 준비

```bash
# 프로젝트 디렉토리로 이동
cd /app/Datablocks

# 파일 확인
ls -la docker-compose.yml .env
```

### 5-2. 전체 실행 (4개 컨테이너 모두)

```bash
docker compose up -d --build
```

| 옵션 | 의미 |
|------|------|
| `up` | 컨테이너를 만들고 시작해라 |
| `-d` | 백그라운드에서 실행 (detach). 이거 안 쓰면 터미널이 묶임 |
| `--build` | 소스코드가 바뀌었으면 이미지를 새로 빌드해라 |

```
실행하면 이런 일이 순서대로 일어납니다:

  1. MariaDB 컨테이너 시작 (DB가 먼저!)
           |
           | healthcheck 통과 (DB 준비 완료)
           v
  2. DLM 컨테이너 시작 (Spring Boot)
           |
           | 시작 확인
           v
  3. DLM-Privacy-AI 컨테이너 시작
  4. Portainer 컨테이너 시작 (독립)
```

### 5-3. 개별 컨테이너만 실행

특정 컨테이너만 실행하고 싶을 때:

```bash
# DLM만 실행 (의존하는 MariaDB도 자동으로 함께 시작됨)
docker compose up -d dlm

# Privacy-AI만 실행
docker compose up -d dlm-privacy-ai

# Portainer만 실행
docker compose up -d portainer
```

### 5-4. 한 개만 재빌드

코드를 수정한 후 해당 컨테이너만 다시 빌드하고 싶을 때:

```bash
# DLM 소스코드 수정 후 DLM만 재빌드 + 재시작
docker compose up -d --build dlm

# Privacy-AI 소스코드 수정 후 재빌드 + 재시작
docker compose up -d --build dlm-privacy-ai
```

> **참고**: `--build` 옵션 없이 `docker compose up -d dlm`만 하면
> 이전에 빌드한 이미지를 그대로 사용합니다. 코드를 수정했다면 반드시 `--build`를 붙이세요.

### 5-5. 로그 확인

```bash
# DLM 로그 실시간 확인 (-f = follow, 실시간으로 따라감)
docker logs -f dlm-app

# Privacy-AI 로그 확인
docker logs -f dlm-privacy-ai

# MariaDB 로그 확인
docker logs -f dlm-mariadb

# 최근 100줄만 보기
docker logs --tail 100 dlm-app

# 최근 100줄 + 실시간 따라가기
docker logs --tail 100 -f dlm-app
```

> **실시간 로그 보기를 종료하려면**: `Ctrl + C` 를 누르세요 (컨테이너가 종료되는 게 아닙니다!)

### 5-6. 상태 확인

```bash
# 실행 중인 컨테이너 목록
docker ps
```

정상이면 아래처럼 4개 컨테이너가 모두 `Up` 상태로 보입니다:

```
CONTAINER ID   IMAGE                         STATUS                    PORTS                    NAMES
a1b2c3d4e5f6   datablocks-dlm                Up 2 hours (healthy)      0.0.0.0:8080->8080/tcp   dlm-app
b2c3d4e5f6a7   datablocks-dlm-privacy-ai     Up 2 hours (healthy)      0.0.0.0:8000->8000/tcp   dlm-privacy-ai
c3d4e5f6a7b8   mariadb:10.11                 Up 2 hours (healthy)      0.0.0.0:3306->3306/tcp   dlm-mariadb
d4e5f6a7b8c9   portainer/portainer-ce:lts    Up 2 hours                0.0.0.0:9000->9000/tcp   dlm-portainer
```

| STATUS | 의미 |
|--------|------|
| `Up X hours` | 정상 실행 중 |
| `Up X hours (healthy)` | 정상 실행 + 헬스체크 통과 |
| `Restarting` | 계속 재시작됨 (문제 있음!) |
| 목록에 안 보임 | 중지된 상태 |

### 5-7. 중지

```bash
# 전체 중지 (컨테이너 삭제, 데이터는 보존됨)
docker compose down

# 개별 중지 (컨테이너는 남아있고 멈추기만 함)
docker compose stop dlm
docker compose stop dlm-privacy-ai

# 개별 중지 후 다시 시작
docker compose start dlm
```

> **`down` vs `stop` 차이점**:
> - `stop` = 전원 끄기 (컨테이너가 남아있음, `start`로 재시작 가능)
> - `down` = 정리하고 치우기 (컨테이너 삭제, 다시 `up`으로 새로 만들어야 함)
> - 둘 다 데이터(DB, 로그 등)는 **볼륨(Volume)에 안전하게 보존**됩니다

---

## 6. 고객사 배포 방법

### 전체 흐름 요약

```
  [1단계]               [2단계]            [3단계]          [4단계]
  파일 준비       -->   설정 수정    -->    빌드 & 실행  -->  확인
  (필요한 파일         (.env.customer     (docker compose    (브라우저로
   복사)                에서 DB IP         up -d --build)     접속 테스트)
                        수정)
```

### 6-1. 필요한 파일 준비

고객사 서버에 아래 파일/폴더를 복사합니다:

```bash
# 복사해야 할 파일 목록
/app/Datablocks/
|-- docker-compose.customer.yml     # 필수
|-- .env.customer                   # 필수
|-- DLM/                            # 필수 (전체 폴더)
|   |-- Dockerfile
|   |-- src/
|   |-- gradle/
|   |-- gradlew
|   |-- settings.gradle
|   |-- build.gradle
|   |-- lombok.config
|   |-- libs/
|-- DLM-Privacy-AI/                 # 필수 (전체 폴더)
|   |-- Dockerfile
|   |-- app/
|   |-- requirements.txt
```

> **복사 불필요**: `mariadb/` 폴더, `docker-compose.yml`, `.env` (이것들은 개발환경 전용)

복사 예시 (개발서버에서 실행):

```bash
# 방법 1: scp로 복사 (고객사 서버 IP가 10.0.0.50인 경우)
scp -r /app/Datablocks/DLM \
       /app/Datablocks/DLM-Privacy-AI \
       /app/Datablocks/docker-compose.customer.yml \
       /app/Datablocks/.env.customer \
       사용자@10.0.0.50:/app/Datablocks/

# 방법 2: tar로 묶어서 복사
cd /app/Datablocks
tar czf dlm-deploy.tar.gz \
    DLM/ \
    DLM-Privacy-AI/ \
    docker-compose.customer.yml \
    .env.customer

scp dlm-deploy.tar.gz 사용자@10.0.0.50:/app/

# 고객사 서버에서 압축 해제
ssh 사용자@10.0.0.50
cd /app
tar xzf dlm-deploy.tar.gz -C /app/Datablocks/
```

### 6-2. .env.customer 수정

고객사 서버에서 `.env.customer` 파일을 열어 **DB 접속 정보만 수정**합니다:

```bash
cd /app/Datablocks
vi .env.customer
```

수정할 부분 (별표 표시):

```properties
# ★ 고객사 DB 서버 IP로 변경 (예: 172.16.0.50)
SPRING_DATASOURCE_URL=jdbc:mariadb://172.16.0.50:3306/cotdl?serverTimezone=UTC&autoReconnect=true&allowMultiQueries=true

# ★ Privacy-AI도 같은 DB IP로 변경
PRIVACY_AI_DB_HOST=172.16.0.50
PRIVACY_AI_DB_PORT=3306

# ★ DB 비밀번호가 다르면 변경
PRIVACY_AI_DB_PASSWORD=고객사DB비밀번호
```

> **중요**: `PRIVACY_AI_DLM_API_URL=http://dlm:8080` 은 수정하지 마세요!
> 이것은 Docker 내부 통신용 주소이므로 `dlm` 그대로 두어야 합니다.

### 6-3. 빌드 및 실행

```bash
cd /app/Datablocks

# 빌드 + 실행 (첫 실행 시 5~10분 소요)
docker compose -f docker-compose.customer.yml --env-file .env.customer up -d --build
```

명령어가 기니까 분해해서 설명하겠습니다:

| 부분 | 의미 |
|------|------|
| `docker compose` | Docker Compose 명령 |
| `-f docker-compose.customer.yml` | 이 설정 파일을 사용해라 (기본은 docker-compose.yml) |
| `--env-file .env.customer` | 환경변수는 이 파일에서 읽어라 |
| `up -d --build` | 백그라운드에서 빌드하고 실행해라 |

### 6-4. 동작 확인

```bash
# 1. 컨테이너 상태 확인
docker ps
```

정상이면 2개 컨테이너가 `Up` 상태:

```
CONTAINER ID   IMAGE                         STATUS                    PORTS                    NAMES
a1b2c3d4e5f6   datablocks-dlm                Up 5 minutes (healthy)    0.0.0.0:8080->8080/tcp   dlm-app
b2c3d4e5f6a7   datablocks-dlm-privacy-ai     Up 3 minutes (healthy)    0.0.0.0:8000->8000/tcp   dlm-privacy-ai
```

```bash
# 2. DLM 로그 확인 (Spring Boot가 정상 기동되었는지)
docker logs dlm-app 2>&1 | tail -20
```

`Started` 메시지가 보이면 성공:

```
... Started DlmApplication in 25.3 seconds
```

```bash
# 3. Privacy-AI 헬스체크
curl http://localhost:8000/health
```

`{"status":"ok"}` 이 나오면 성공.

```bash
# 4. 웹 브라우저로 접속
# http://고객사서버IP:8080
```

로그인 화면이 나오면 배포 완료!

### 6-5. 고객사 배포 이후 유지보수 명령어

```bash
# --- 전체 재시작 ---
cd /app/Datablocks
docker compose -f docker-compose.customer.yml --env-file .env.customer down
docker compose -f docker-compose.customer.yml --env-file .env.customer up -d --build

# --- DLM만 재빌드 (코드 업데이트 시) ---
docker compose -f docker-compose.customer.yml --env-file .env.customer up -d --build dlm

# --- Privacy-AI만 재빌드 ---
docker compose -f docker-compose.customer.yml --env-file .env.customer up -d --build dlm-privacy-ai

# --- 로그 확인 ---
docker logs -f dlm-app
docker logs -f dlm-privacy-ai

# --- 전체 중지 ---
docker compose -f docker-compose.customer.yml --env-file .env.customer down
```

> **팁**: 명령어가 길어서 불편하다면 아래처럼 alias를 만들 수 있습니다.
>
> ```bash
> # ~/.bashrc 에 추가
> alias dlm-up='cd /app/Datablocks && docker compose -f docker-compose.customer.yml --env-file .env.customer up -d --build'
> alias dlm-down='cd /app/Datablocks && docker compose -f docker-compose.customer.yml --env-file .env.customer down'
> alias dlm-logs='docker logs -f dlm-app'
> alias dlm-ps='docker ps'
>
> # 적용
> source ~/.bashrc
>
> # 사용
> dlm-up        # 시작
> dlm-down      # 중지
> dlm-logs      # 로그
> dlm-ps        # 상태
> ```

---

## 7. 자주 쓰는 Docker 명령어

### 기본 명령어 치트시트

```
+-------------------------------------------------------------------+
|                    Docker 명령어 치트시트                            |
+-------------------------------------------------------------------+
|                                                                    |
|  상태 확인                                                         |
|  ----------                                                        |
|  docker ps                    실행 중인 컨테이너 목록               |
|  docker ps -a                 모든 컨테이너 (중지된 것 포함)         |
|  docker images                다운로드/빌드된 이미지 목록            |
|  docker stats                 CPU/메모리 실시간 사용량               |
|                                                                    |
|  로그                                                              |
|  ----                                                              |
|  docker logs 컨테이너명       로그 전체 보기                        |
|  docker logs -f 컨테이너명    로그 실시간 추적 (Ctrl+C로 종료)       |
|  docker logs --tail 100 이름  최근 100줄만 보기                     |
|                                                                    |
|  컨테이너 제어                                                      |
|  ------------                                                      |
|  docker stop 컨테이너명       컨테이너 중지                         |
|  docker start 컨테이너명      중지된 컨테이너 시작                   |
|  docker restart 컨테이너명    재시작                                |
|                                                                    |
|  컨테이너 내부 접속                                                  |
|  ----------------                                                  |
|  docker exec -it 컨테이너명 bash    컨테이너 안으로 들어가기         |
|  docker exec -it 컨테이너명 sh      bash가 없는 경우 sh 사용        |
|                                                                    |
|  정리                                                              |
|  ----                                                              |
|  docker system df             디스크 사용량 확인                    |
|  docker system prune          안 쓰는 것들 정리 (디스크 확보)        |
|  docker image prune           안 쓰는 이미지 삭제                   |
|                                                                    |
+-------------------------------------------------------------------+
```

### Docker Compose 명령어 치트시트

```
+-------------------------------------------------------------------+
|               Docker Compose 명령어 치트시트                        |
+-------------------------------------------------------------------+
|                                                                    |
|  실행/중지                                                         |
|  --------                                                          |
|  docker compose up -d             전체 실행 (백그라운드)             |
|  docker compose up -d --build     전체 빌드 + 실행                  |
|  docker compose up -d 서비스명    특정 서비스만 실행                  |
|  docker compose down              전체 중지 + 삭제                  |
|  docker compose stop              전체 중지 (삭제 안 함)             |
|  docker compose stop 서비스명     특정 서비스만 중지                  |
|  docker compose start 서비스명    중지한 서비스 시작                  |
|  docker compose restart 서비스명  특정 서비스 재시작                  |
|                                                                    |
|  상태/로그                                                         |
|  --------                                                          |
|  docker compose ps                서비스 상태 목록                   |
|  docker compose logs              전체 로그                         |
|  docker compose logs -f 서비스명  특정 서비스 로그 실시간             |
|                                                                    |
|  고객사 전용 (-f와 --env-file 추가)                                 |
|  ---------------------------------                                 |
|  docker compose -f docker-compose.customer.yml \                   |
|    --env-file .env.customer up -d --build                          |
|                                                                    |
+-------------------------------------------------------------------+
```

### 자주 쓰는 조합 예시

```bash
# DLM 컨테이너 안에서 Java 버전 확인
docker exec -it dlm-app java -version

# MariaDB 컨테이너 안에서 DB 접속
docker exec -it dlm-mariadb mariadb -u root -p

# Privacy-AI 컨테이너 안에서 Python 버전 확인
docker exec -it dlm-privacy-ai python --version

# 모든 컨테이너의 CPU/메모리 사용량 실시간 모니터링
docker stats

# 디스크 용량이 부족할 때 정리
docker system prune -f            # 미사용 컨테이너/네트워크/이미지 삭제
docker volume prune -f            # 미사용 볼륨 삭제 (주의: 데이터 삭제됨!)
```

---

## 8. 트러블슈팅

### 문제 1: 포트 충돌 (Port Conflict)

**증상**: 컨테이너가 시작되지 않고, 아래와 같은 에러 발생

```
Error: Bind for 0.0.0.0:8080 failed: port is already allocated
```

**원인**: 해당 포트를 이미 다른 프로그램이 사용 중

**해결**:

```bash
# 8080 포트를 사용 중인 프로세스 찾기
sudo lsof -i :8080
# 또는
sudo ss -tlnp | grep 8080

# 해당 프로세스 종료 (PID는 위 명령에서 확인)
sudo kill -9 [PID]

# 다시 실행
docker compose up -d
```

또는 포트를 변경하는 방법:

```bash
# .env.customer에서 포트 변경 (고객사 배포 시)
DLM_PORT=18080     # 8080 대신 18080 사용
AI_PORT=18000      # 8000 대신 18000 사용
```

---

### 문제 2: DB 연결 실패 (Connection Refused)

**증상**: DLM 로그에서 아래와 같은 에러

```
Communications link failure
The last packet sent successfully to the server was 0 milliseconds ago.
```

**원인 & 해결**:

```bash
# 원인 1: MariaDB 컨테이너가 아직 준비 안 됨
# --> 잠시 기다리기 (30초~1분). MariaDB는 시작이 느림
docker logs -f dlm-mariadb   # "ready for connections" 메시지 확인

# 원인 2: (고객사) DB 서버 IP가 잘못됨
# --> .env.customer 파일에서 IP 확인
cat .env.customer | grep DB_HOST

# 원인 3: (고객사) DB 서버에서 접근을 차단
# --> 고객사 DB 서버의 방화벽 확인
# --> DB에서 외부 접속 허용 확인
#     MariaDB에서: GRANT ALL ON cotdl.* TO 'cotdl'@'%' IDENTIFIED BY '비밀번호';

# 원인 4: (고객사) DB 서버 포트가 다름
# --> .env.customer에서 포트 확인
cat .env.customer | grep DB_PORT
```

---

### 문제 3: 컨테이너가 계속 재시작됨 (Restarting)

**증상**: `docker ps` 에서 STATUS가 `Restarting`

```
CONTAINER ID   IMAGE            STATUS                          NAMES
a1b2c3d4e5f6   datablocks-dlm   Restarting (1) 5 seconds ago    dlm-app
```

**해결**:

```bash
# 1단계: 에러 로그 확인 (가장 중요!)
docker logs dlm-app 2>&1 | tail -50

# 2단계: 로그에서 에러 메시지를 확인하고 원인 파악
# 흔한 원인들:
#   - "java.lang.OutOfMemoryError" -> 메모리 부족
#   - "Connection refused"         -> DB 연결 실패
#   - "Address already in use"     -> 포트 충돌
#   - "FileNotFoundException"      -> 설정 파일 경로 오류

# 3단계: 컨테이너를 먼저 중지하고 문제 해결
docker compose stop dlm
# (문제 해결 후)
docker compose up -d dlm
```

---

### 문제 4: 이미지 빌드 실패

**증상**: `docker compose up -d --build` 시 에러

```
ERROR: failed to solve: ...
```

**해결**:

```bash
# 원인 1: 인터넷 연결 안 됨 (패키지 다운로드 실패)
ping google.com

# 원인 2: 디스크 공간 부족
df -h
docker system prune -f      # Docker가 사용하는 불필요한 공간 정리

# 원인 3: 캐시 문제 (이전 빌드 찌꺼기)
docker compose build --no-cache dlm
docker compose up -d dlm
```

---

### 문제 5: Permission Denied (docker 명령 실행 안 됨)

**증상**:

```
Got permission denied while trying to connect to the Docker daemon socket
```

**해결**:

```bash
# 방법 1: sudo를 앞에 붙이기
sudo docker ps

# 방법 2: docker 그룹에 사용자 추가 (권장, 한번만 하면 됨)
sudo usermod -aG docker $USER
# 로그아웃 후 다시 로그인
```

---

### 문제 6: 컨테이너 내부 파일 확인이 필요할 때

```bash
# DLM 컨테이너 내부로 접속
docker exec -it dlm-app sh

# 컨테이너 안에서 파일 확인
ls /app/
cat /app/logs/dlm.log

# 컨테이너에서 나오기
exit
```

---

### 문제 7: "no space left on device"

```bash
# Docker가 사용하는 디스크 확인
docker system df

# 안 쓰는 이미지/컨테이너 전부 삭제
docker system prune -a -f

# 이렇게 하면 보통 수~수십 GB 확보됨
```

---

### 트러블슈팅 순서도

```
  컨테이너가 안 됨!
       |
       v
  [docker ps 로 상태 확인]
       |
       +-- 컨테이너가 안 보인다
       |      |
       |      v
       |   [docker ps -a 로 전체 확인]
       |      |
       |      +-- "Exited" 상태 --> docker logs 이름 으로 에러 확인
       |      +-- 아예 없다    --> docker compose up -d 다시 실행
       |
       +-- "Restarting" 상태
       |      |
       |      v
       |   [docker logs 이름 으로 에러 확인]
       |      |
       |      +-- DB 연결 에러  --> DB IP/포트/방화벽 확인
       |      +-- 메모리 에러   --> 서버 RAM 확인
       |      +-- 기타         --> 에러 메시지 구글 검색
       |
       +-- "Up" 상태인데 접속이 안 됨
              |
              v
           [방화벽 확인]
              |
              +-- sudo firewall-cmd --list-ports  (CentOS)
              +-- sudo ufw status                  (Ubuntu)
              |
              +-- 포트 열기:
                  sudo firewall-cmd --add-port=8080/tcp --permanent  (CentOS)
                  sudo ufw allow 8080/tcp                             (Ubuntu)
```

---

## 9. .env 파일 설명

### 개발환경: `.env`

| 변수명 | 값 (예시) | 설명 |
|--------|-----------|------|
| `MARIADB_ROOT_PASSWORD` | `!Dlm1234` | MariaDB root 비밀번호 |
| `SPRING_PROFILES_ACTIVE` | `local` | Spring 프로파일 (local/dev/prod) |
| `SPRING_DATASOURCE_URL` | `jdbc:mariadb://dlm-mariadb:3306/cotdl?...` | DB 접속 URL. `dlm-mariadb`는 Docker 내부 서비스명 |
| `SPRING_DATASOURCE_USERNAME` | `cotdl` | DB 계정명 (v1.0.0 부터 env 필수) |
| `SPRING_DATASOURCE_PASSWORD` | `!Dlm1234` | DB 암호 (v1.0.0 부터 env 필수) |
| `PRIVACY_AI_DB_HOST` | `dlm-mariadb` | Privacy-AI가 접속할 DB 호스트 |
| `PRIVACY_AI_DB_PORT` | `3306` | DB 포트 |
| `PRIVACY_AI_DB_NAME` | `cotdl` | DB 이름 |
| `PRIVACY_AI_DB_USER` | `cotdl` | DB 사용자 |
| `PRIVACY_AI_DB_PASSWORD` | `!Dlm1234` | DB 비밀번호 |
| `PRIVACY_AI_DLM_API_URL` | `http://dlm:8080` | Privacy-AI에서 DLM으로 통신하는 URL |
| `PRIVACY_AI_DEBUG` | `false` | 디버그 모드 (true면 상세 로그) |
| `MAIL_HOST` | `smtp.gmail.com` | 메일 서버 (선택) |
| `MAIL_PORT` | `587` | 메일 포트 (선택) |
| `MAIL_USERNAME` | (비어있음) | 메일 계정 (선택) |
| `MAIL_PASSWORD` | (비어있음) | 메일 비밀번호 (선택) |
| `PRIVACY_AI_LLM_ENABLED` | `false` | LLM 기능 사용 여부 |
| `PRIVACY_AI_LLM_API_URL` | (비어있음) | LLM API URL (예: OpenAI) |
| `PRIVACY_AI_LLM_API_KEY` | (비어있음) | LLM API 키 |
| `PRIVACY_AI_LLM_MODEL` | (비어있음) | LLM 모델명 (예: gpt-4) |

### 고객사 배포: `.env.customer`

| 변수명 | 수정 필요? | 설명 |
|--------|-----------|------|
| `SPRING_DATASOURCE_URL` | **반드시 수정** | 고객사 DB 서버 IP로 변경 |
| `SPRING_DATASOURCE_USERNAME` | **확인 필요** | DB 계정 (보통 `cotdl`) |
| `SPRING_DATASOURCE_PASSWORD` | **확인 필요** | DB 암호 (현장 실암호) |
| `SPRING_PROFILES_ACTIVE` | 보통 그대로 | `local` 유지 |
| `DLM_PORT` | 필요시 수정 | DLM 접속 포트 (기본 8080) |
| `PRIVACY_AI_DB_HOST` | **반드시 수정** | 고객사 DB 서버 IP |
| `PRIVACY_AI_DB_PORT` | 필요시 수정 | DB 포트 (기본 3306) |
| `PRIVACY_AI_DB_NAME` | 보통 그대로 | `cotdl` |
| `PRIVACY_AI_DB_USER` | 필요시 수정 | DB 사용자 |
| `PRIVACY_AI_DB_PASSWORD` | **확인 필요** | DB 비밀번호 |
| `PRIVACY_AI_DLM_API_URL` | **수정 금지** | Docker 내부 통신용. 항상 `http://dlm:8080` |
| `AI_PORT` | 필요시 수정 | Privacy-AI 포트 (기본 8000) |
| `MAIL_*` | 선택 | 메일 알림 기능 사용 시 설정 |
| `PRIVACY_AI_LLM_*` | 선택 | LLM 기능 사용 시 설정 |

### Docker 내부 통신 vs 외부 통신

```
  .env 파일에서 자주 헷갈리는 부분:

  PRIVACY_AI_DLM_API_URL=http://dlm:8080
                              ^^^
                              이건 "서버 IP"가 아님!
                              Docker 내부 서비스 이름임!

  +-----------------------------------------------------------+
  |  Docker 내부 (컨테이너 끼리)                                |
  |                                                            |
  |   dlm-privacy-ai  ---> http://dlm:8080 ----> dlm-app      |
  |                         ^^^                                |
  |                         Docker가 자동으로                   |
  |                         "dlm"이라는 이름을                  |
  |                         dlm-app 컨테이너의                  |
  |                         IP로 변환해줌                       |
  +-----------------------------------------------------------+

  +-----------------------------------------------------------+
  |  Docker 외부 (사용자/브라우저)                               |
  |                                                            |
  |   브라우저  ---> http://서버IP:8080 ----> dlm-app           |
  |                  ^^^^^^^^^^^^                               |
  |                  실제 서버 IP 사용                           |
  +-----------------------------------------------------------+

  결론:
  - .env 안의 URL은 Docker 내부 통신 --> 서비스 이름(dlm, dlm-mariadb) 사용
  - 브라우저 접속은 Docker 외부 통신 --> 실제 서버 IP 사용
```

---

## 부록: 용어 정리

| 용어 | 의미 |
|------|------|
| **이미지 (Image)** | 프로그램 실행에 필요한 모든 것을 담은 템플릿. 레시피와 같음 |
| **컨테이너 (Container)** | 이미지를 실행한 것. 실제 돌아가는 프로세스 |
| **Dockerfile** | 이미지를 만드는 설명서 (어떤 OS, 어떤 프로그램, 어떤 설정) |
| **docker-compose.yml** | 여러 컨테이너를 한 번에 관리하는 설정 파일 |
| **볼륨 (Volume)** | 컨테이너가 삭제되어도 데이터가 남는 저장소 |
| **네트워크 (Network)** | 컨테이너들끼리 통신할 수 있는 가상 네트워크 |
| **서비스 (Service)** | docker-compose.yml에 정의된 각 컨테이너 설정 단위 |
| **빌드 (Build)** | Dockerfile을 읽어서 이미지를 만드는 과정 |
| **포트 바인딩** | 호스트의 포트를 컨테이너 포트에 연결 (예: `8080:8080`) |
| **헬스체크 (Healthcheck)** | 컨테이너가 정상인지 주기적으로 확인하는 기능 |
| **WAR** | Java 웹 애플리케이션 패키지 파일 (Web Application Archive) |

---

## 부록: 서버 최소 사양

| 구분 | 개발환경 (4개 컨테이너) | 고객사 배포 (2개 컨테이너) |
|------|------------------------|--------------------------|
| CPU | 8코어 이상 | 4코어 이상 |
| RAM | 32GB 이상 | 16GB 이상 |
| 디스크 | 100GB 이상 | 50GB 이상 |
| OS | CentOS 7+, Ubuntu 20.04+ | CentOS 7+, Ubuntu 20.04+ |

### 컨테이너별 리소스 할당

```
개발환경 (32GB RAM 서버 기준):
+--------------------+--------+---------+
| 컨테이너            | CPU    | 메모리   |
+--------------------+--------+---------+
| MariaDB            | 2 코어 |  4 GB   |
| DLM (Spring Boot)  | 3 코어 | 12 GB   |
| DLM-Privacy-AI     | 2 코어 |  8 GB   |
| Portainer          | 0.5코어|  0.5 GB |
| OS/Docker 예약      | 1 코어 |  8 GB   |
+--------------------+--------+---------+
| 합계               | ~8코어 | ~32 GB  |
+--------------------+--------+---------+
```
