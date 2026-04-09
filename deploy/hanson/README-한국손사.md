# DLM 배포 가이드 — 한국손사

> 폐쇄망 Ubuntu / Docker 설치됨 / MariaDB 컨테이너 이미 운영 중
> 작성일: 2026-04-08 | 갱신: 2026-04-09

---

## 전체 흐름

```
개발PC (WSL)                       손사 서버 (Ubuntu)
============                       ================

deploy/hanson/ 폴더
    |                              기존 MariaDB 컨테이너 운영 중
    | USB 복사                      (cotdl DB 구성 완료)
    v
                               [WAS 서버]
                               bash scripts/deploy.sh
                                   → 기존 mariadb 컨테이너 감지
                                   → 네트워크 자동 감지
                                   → 이미지 로드
                                   → DLM + Privacy-AI 실행
                                   |
                                   v
                               +-------+    +-----------+
                               |  DLM  |    | Privacy-AI|
                               | :8082 |    |   :8000   |
                               +---+---+    +-----+-----+
                                   |              |
                                   +--------------+
                                         |
                                  기존 mariadb 컨테이너
                                  (같은 Docker 네트워크)
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
deploy/hanson/
├── images/
│   ├── dlm-app.tar.gz             ← DLM 이미지 (~301MB)
│   └── dlm-privacy-ai.tar.gz     ← Privacy-AI 이미지 (~78MB)
├── docker-compose.hanson.yml      ← 손사 전용 Docker Compose
├── .env.hanson                    ← 손사 전용 환경변수
├── mariadb/                       ← 참고용 (DB 이미 구성됨, 실행 불필요)
│   ├── DLM_DATABASE_INIT.sql
│   ├── cotdl_dump.sql.data
│   └── custom-prod.cnf
├── scripts/
│   └── deploy.sh                  ← DLM 배포 스크립트
└── README-한국손사.md              ← 이 문서
```

---

## 2. 최초 배포 (deploy.sh)

```bash
bash scripts/deploy.sh
```

스크립트 실행 흐름:

| 순서 | 작업 | 설명 |
|------|------|------|
| 1 | MariaDB 컨테이너 감지 | 기존 `mariadb` 컨테이너 확인 |
| 2 | 네트워크 감지 | mariadb의 Docker 네트워크 자동 감지 |
| 3 | Docker 이미지 로드 | dlm-app.tar.gz, dlm-privacy-ai.tar.gz |
| 4 | 설정 확인 | 감지 결과 표시 → Enter로 유지 또는 변경 |
| 5 | 컨테이너 실행 | docker compose up -d + 헬스체크 |

```
  ──────────────────────────────────────────
  감지/설정 결과 확인 (Enter=유지, 입력=변경)
  ──────────────────────────────────────────

  MariaDB 컨테이너 [mariadb]:           ← Enter
  MariaDB 네트워크 [xxx_default]:       ← Enter
  DLM 포트 [8082]:                      ← Enter
  Privacy-AI 포트 [8000]:               ← Enter
```

---

## 3. 운영 명령어

### 기본 명령어

```bash
cd /app/Datablocks

# ─── 상태 확인 ───
docker ps                                            # 전체 컨테이너 상태
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"   # 간결하게

# ─── 시작 / 중지 / 재시작 ───
MARIADB_NETWORK=<네트워크명> docker compose -f docker-compose.hanson.yml up -d       # 전체 시작
MARIADB_NETWORK=<네트워크명> docker compose -f docker-compose.hanson.yml down         # 전체 중지
MARIADB_NETWORK=<네트워크명> docker compose -f docker-compose.hanson.yml restart      # 전체 재시작
MARIADB_NETWORK=<네트워크명> docker compose -f docker-compose.hanson.yml restart dlm  # DLM만 재시작
```

> **참고**: `MARIADB_NETWORK` 값은 deploy.sh 실행 시 `.env.hanson`에 자동 기록됩니다.
> `.env.hanson`에 이미 기록되어 있으면 `source .env.hanson && MARIADB_NETWORK=$MARIADB_NETWORK docker compose ...` 로 사용.

### 단축 명령 등록 (권장)

```bash
# .env.hanson 에서 네트워크명 읽어서 alias 등록
MARIADB_NETWORK=$(grep '^MARIADB_NETWORK=' /app/Datablocks/.env.hanson | cut -d= -f2)

cat >> ~/.bashrc << EOF
export MARIADB_NETWORK=${MARIADB_NETWORK}
alias dlm-ps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm|mariadb"'
alias dlm-up='cd /app/Datablocks && MARIADB_NETWORK=\$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml up -d'
alias dlm-down='cd /app/Datablocks && MARIADB_NETWORK=\$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml down'
alias dlm-restart='cd /app/Datablocks && MARIADB_NETWORK=\$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml restart'
alias dlm-restart-app='cd /app/Datablocks && MARIADB_NETWORK=\$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml restart dlm'
alias dlm-restart-ai='cd /app/Datablocks && MARIADB_NETWORK=\$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml restart dlm-privacy-ai'
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

## 4. 패치 적용

### 4-1. 개발PC에서 이미지 준비 (WSL)

```bash
cd /app/Datablocks

# 1. 코드 수정 후 이미지 빌드 (--no-cache 권장)
docker compose build --no-cache dlm                    # DLM만 변경된 경우
docker compose build --no-cache dlm dlm-privacy-ai     # 둘 다 변경된 경우

# 2. 이미지 추출
docker save datablocks-dlm:latest | gzip > deploy/hanson/images/dlm-app.tar.gz
docker save datablocks-dlm-privacy-ai:latest | gzip > deploy/hanson/images/dlm-privacy-ai.tar.gz

# 3. Windows → USB로 복사
cp -r deploy/hanson/images/ /mnt/c/Users/사용자명/Desktop/hanson-patch/
```

### 4-2. 손사 서버에서 패치 적용

```bash
# 0. 현재 이미지 백업 (권장)
mkdir -p /app/backup
docker save datablocks-dlm:latest | gzip > /app/backup/dlm-app-backup-$(date +%Y%m%d).tar.gz

# 1. USB 파일을 서버로 복사
mkdir -p /tmp/patch
cp -r /media/usb/* /tmp/patch/

# 2. 현재 컨테이너 중지
cd /app/Datablocks
source .env.hanson
MARIADB_NETWORK=$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml down

# 3. 새 이미지 로드
docker load < /tmp/patch/dlm-app.tar.gz
#  → "Loaded image: datablocks-dlm:latest" 메시지 확인

# Privacy-AI도 변경된 경우:
docker load < /tmp/patch/dlm-privacy-ai.tar.gz

# 4. 컨테이너 재시작
MARIADB_NETWORK=$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml up -d

# 5. 동작 확인
docker ps                                            # 컨테이너 2개 Up 확인
docker logs -f --tail 50 dlm-app                     # 로그 확인 (Ctrl+C 종료)
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -10   # 에러 확인
```

브라우저 접속: `http://WAS서버IP:8082` → 로그인 → 변경 기능 확인

### 4-3. DB 패치가 있는 경우

```bash
# 기존 mariadb 컨테이너에서 SQL 실행
docker exec -i mariadb mysql -u cotdl -p cotdl < /tmp/patch/PATCH_YYYYMMDD_설명.sql
```

### 4-4. 롤백 (문제 발생 시)

```bash
cd /app/Datablocks
source .env.hanson

# 1. 문제 컨테이너 중지
MARIADB_NETWORK=$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml down

# 2. 백업 이미지 복원
docker load < /app/backup/dlm-app-backup-20260409.tar.gz

# 3. 재시작
MARIADB_NETWORK=$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml up -d

# 4. 확인
docker ps
docker logs -f --tail 50 dlm-app
```

---

## 5. 서버 재부팅 시

Docker에 `restart: unless-stopped` 설정이 되어 있으므로:

```
서버 재부팅 → Docker 자동 시작 → DLM 컨테이너 자동 시작
```

확인:
```bash
sudo systemctl is-enabled docker       # enabled 이면 OK
```

> **주의**: 기존 `mariadb` 컨테이너가 먼저 시작되어야 DLM이 DB에 접속 가능합니다.
> mariadb도 `restart: unless-stopped` 또는 `restart: always`이면 자동 시작됩니다.

---

## 6. 트러블슈팅

| 증상 | 원인 | 해결 |
|------|------|------|
| 웹 접속 안 됨 | 방화벽 | `sudo ufw allow 8082/tcp` |
| 로그인 후 에러 | DB 연결 실패 | `docker logs dlm-app --tail 50` 확인 |
| `Connection refused` | mariadb 미시작 | `docker ps`로 mariadb 확인 |
| `Access denied` | DB 비밀번호 불일치 | `.env.hanson`의 PRIVACY_AI_DB_PASSWORD 확인 |
| `Unknown host` | 네트워크 연결 안 됨 | `docker network inspect <네트워크명>` 확인 |
| 컨테이너 재시작 반복 | 메모리/에러 | `docker logs dlm-app` 확인 |
| 포트 충돌 | 기존 서비스 | `.env.hanson`에서 DLM_PORT 변경 |
| compose 에러 | MARIADB_NETWORK 미설정 | `source .env.hanson` 후 재실행 |

### 빠른 진단

```bash
# 1. 컨테이너 상태
docker ps -a | grep dlm

# 2. DLM 에러 확인
docker logs dlm-app 2>&1 | grep -i "error\|exception" | tail -20

# 3. DB 연결 테스트 (DLM 컨테이너 안에서)
docker exec dlm-app sh -c "wget -qO- --timeout=3 http://localhost:8080/ && echo OK || echo FAIL"

# 4. mariadb 접속 테스트
docker exec dlm-app sh -c "nc -zv mariadb 3306 2>&1 || echo 'DB 연결 실패'"

# 5. 네트워크 상태
docker network inspect $(grep '^MARIADB_NETWORK=' /app/Datablocks/.env.hanson | cut -d= -f2) 2>/dev/null | grep -A2 '"Name"'
```

---

## 7. 방화벽 설정

```bash
# UFW
sudo ufw allow 8082/tcp    # DLM 웹
sudo ufw reload

# iptables
sudo iptables -A INPUT -p tcp --dport 8082 -j ACCEPT
```

---

## 체크리스트

```
최초 배포
  ☐ DB: 이미 구성 완료 (cotdl DB + 데이터)
  ☐ bash scripts/deploy.sh 실행
    ☐ 기존 mariadb 컨테이너 감지 OK
    ☐ 네트워크 감지 OK
    ☐ 이미지 로드 완료
    ☐ 포트 확인 (DLM=8082, AI=8000)
    ☐ 컨테이너 2개 Running
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
