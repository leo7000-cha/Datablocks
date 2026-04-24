#!/bin/bash
# ==============================================================================
# DLM 배포 스크립트 — 한국손사 (PROD: OS 설치형 MariaDB)
# 사전 조건:
#   - Docker 설치 완료
#   - 호스트 OS 에 MariaDB 설치·실행 중 (cotdl DB + 데이터 구성 완료)
#   - MariaDB bind-address 가 docker0 브리지 IP 또는 0.0.0.0 을 수신
#   - cotdl 계정이 docker bridge 대역 (예: 172.17.0.0/16) 에서 접속 허용됨
# ==============================================================================
set -uo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $*"; }
warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')]${NC} $*"; }
err()  { echo -e "${RED}[$(date '+%H:%M:%S')]${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEPLOY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_DIR="/app/Datablocks"

echo ""
echo "=============================================="
echo "  DLM 배포 — 한국손사 (PROD / OS MariaDB)"
echo "=============================================="
echo ""

# --- 사전 확인 ---
if ! docker info &>/dev/null; then
    err "Docker가 실행 중이지 않습니다."
    exit 1
fi
log "Docker: $(docker --version)"

# --- .env 로드 ---
if [ -f "$DEPLOY_ROOT/.env.hanson" ]; then
    source <(grep -v '^\s*#' "$DEPLOY_ROOT/.env.hanson" | grep -v '^\s*$')
fi
MARIADB_HOST="${MARIADB_HOST:-host.docker.internal}"
MARIADB_PORT="${MARIADB_PORT:-3306}"
PRIVACY_AI_DB_USER="${PRIVACY_AI_DB_USER:-cotdl}"
PRIVACY_AI_DB_PASSWORD="${PRIVACY_AI_DB_PASSWORD:-}"
PRIVACY_AI_DB_NAME="${PRIVACY_AI_DB_NAME:-cotdl}"

# ==============================================================================
# STEP 1: 호스트 MariaDB 접속 정보 확인
# ==============================================================================
echo ""
log "=== STEP 1/5: 호스트 MariaDB 접속 정보 확인 ==="

echo ""
echo "  ──────────────────────────────────────────"
echo "  MariaDB 호스트 설정 (Enter=유지, 입력=변경)"
echo "  ──────────────────────────────────────────"
echo ""

read -p "  MariaDB 호스트 [${MARIADB_HOST}]: " NEW_HOST
if [ -n "$NEW_HOST" ]; then
    MARIADB_HOST="$NEW_HOST"
fi

read -p "  MariaDB 포트   [${MARIADB_PORT}]: " NEW_PORT
if [ -n "$NEW_PORT" ]; then
    MARIADB_PORT="$NEW_PORT"
fi

log "MariaDB: ${MARIADB_HOST}:${MARIADB_PORT}"

# ==============================================================================
# STEP 2: MariaDB 접속 테스트 (호스트 OS 에서)
# ==============================================================================
echo ""
log "=== STEP 2/5: MariaDB 연결 테스트 ==="

# host.docker.internal 은 호스트에서는 해석 안 되므로 테스트용 호스트명 변환
TEST_HOST="$MARIADB_HOST"
if [ "$MARIADB_HOST" = "host.docker.internal" ]; then
    # 호스트에서는 127.0.0.1 로 동일한 DB 에 붙음
    TEST_HOST="127.0.0.1"
    log "호스트에서 연결 테스트는 127.0.0.1 로 진행 (컨테이너는 host.docker.internal 사용)"
fi

# mysql 클라이언트 존재 여부
if command -v mysql &>/dev/null; then
    if MYSQL_PWD="$PRIVACY_AI_DB_PASSWORD" mysql \
        -h "$TEST_HOST" -P "$MARIADB_PORT" \
        -u "$PRIVACY_AI_DB_USER" \
        -e "SELECT 1;" "$PRIVACY_AI_DB_NAME" &>/dev/null; then
        log "MariaDB 연결 OK: ${PRIVACY_AI_DB_USER}@${TEST_HOST}:${MARIADB_PORT}/${PRIVACY_AI_DB_NAME}"
    else
        warn "MariaDB 연결 실패 (${PRIVACY_AI_DB_USER}@${TEST_HOST}:${MARIADB_PORT}/${PRIVACY_AI_DB_NAME})"
        warn " - .env.hanson 의 PRIVACY_AI_DB_USER / PRIVACY_AI_DB_PASSWORD 확인"
        warn " - MariaDB grant: cotdl 계정이 docker bridge 대역에서 접속 허용되어야 함"
        read -p "  계속 진행하시겠습니까? [y/N]: " CONTINUE
        [[ "$CONTINUE" =~ ^[Yy]$ ]] || { err "배포 중단"; exit 1; }
    fi
elif command -v nc &>/dev/null; then
    if nc -z -w 3 "$TEST_HOST" "$MARIADB_PORT" &>/dev/null; then
        log "MariaDB 포트 열림: ${TEST_HOST}:${MARIADB_PORT} (TCP OK)"
        warn "mysql 클라이언트가 없어 계정/DB 검증은 생략합니다."
    else
        err "MariaDB 포트 접근 불가: ${TEST_HOST}:${MARIADB_PORT}"
        err " - MariaDB 실행 상태 확인: systemctl status mariadb"
        err " - bind-address 확인: /etc/mysql/mariadb.conf.d/50-server.cnf"
        exit 1
    fi
else
    warn "mysql 또는 nc 가 없어 연결 테스트를 생략합니다."
fi

# ==============================================================================
# STEP 3: Docker 이미지 로드
# ==============================================================================
echo ""
log "=== STEP 3/5: Docker 이미지 로드 ==="

if [ -f "$DEPLOY_ROOT/images/dlm-app.tar.gz" ]; then
    log "DLM 이미지 로드 중... (1~2분)"
    gunzip -c "$DEPLOY_ROOT/images/dlm-app.tar.gz" | docker load
    log "DLM 이미지 로드 완료"
else
    err "이미지 파일 없음: images/dlm-app.tar.gz"
    exit 1
fi

if [ -f "$DEPLOY_ROOT/images/dlm-privacy-ai.tar.gz" ]; then
    log "Privacy-AI 이미지 로드 중..."
    gunzip -c "$DEPLOY_ROOT/images/dlm-privacy-ai.tar.gz" | docker load
    log "Privacy-AI 이미지 로드 완료"
else
    err "이미지 파일 없음: images/dlm-privacy-ai.tar.gz"
    exit 1
fi

echo ""
docker images --format "  {{.Repository}}:{{.Tag}}  ({{.Size}})" | grep -i "datablocks" || true

# ==============================================================================
# STEP 4: 설정 파일 배치
# ==============================================================================
echo ""
log "=== STEP 4/5: 설정 파일 배치 ==="

mkdir -p "$INSTALL_DIR"
cp "$DEPLOY_ROOT/docker-compose.hanson.yml" "$INSTALL_DIR/"
cp "$DEPLOY_ROOT/.env.hanson" "$INSTALL_DIR/"
log "파일 복사 완료: $INSTALL_DIR"

ENV_FILE="$INSTALL_DIR/.env.hanson"

# 수정된 호스트/포트를 .env 에 반영
sed -i "s|^MARIADB_HOST=.*|MARIADB_HOST=${MARIADB_HOST}|g" "$ENV_FILE"
sed -i "s|^MARIADB_PORT=.*|MARIADB_PORT=${MARIADB_PORT}|g" "$ENV_FILE"
# JDBC URL 과 PRIVACY_AI 호스트/포트도 동일하게 반영
sed -i "s|jdbc:mariadb://[^:/]*:[0-9]*/cotdl|jdbc:mariadb://${MARIADB_HOST}:${MARIADB_PORT}/cotdl|g" "$ENV_FILE"
sed -i "s|^PRIVACY_AI_DB_HOST=.*|PRIVACY_AI_DB_HOST=${MARIADB_HOST}|g" "$ENV_FILE"
sed -i "s|^PRIVACY_AI_DB_PORT=.*|PRIVACY_AI_DB_PORT=${MARIADB_PORT}|g" "$ENV_FILE"

FINAL_DLM_PORT=$(grep '^DLM_PORT=' "$ENV_FILE" | cut -d= -f2)
FINAL_AI_PORT=$(grep '^AI_PORT=' "$ENV_FILE" | cut -d= -f2)

echo ""
echo "  ──────────────────────────────────────────"
echo "  서비스 포트 설정 (Enter=유지, 입력=변경)"
echo "  ──────────────────────────────────────────"
echo ""

read -p "  DLM 포트         [${FINAL_DLM_PORT}]: " NEW_DLM_PORT
if [ -n "$NEW_DLM_PORT" ]; then
    sed -i "s|^DLM_PORT=.*|DLM_PORT=${NEW_DLM_PORT}|g" "$ENV_FILE"
    FINAL_DLM_PORT="$NEW_DLM_PORT"
fi

read -p "  Privacy-AI 포트  [${FINAL_AI_PORT}]: " NEW_AI_PORT
if [ -n "$NEW_AI_PORT" ]; then
    sed -i "s|^AI_PORT=.*|AI_PORT=${NEW_AI_PORT}|g" "$ENV_FILE"
    FINAL_AI_PORT="$NEW_AI_PORT"
fi

echo ""
log "최종 설정:"
echo "    MariaDB:  ${MARIADB_HOST}:${MARIADB_PORT} (OS 설치형)"
echo "    DLM:      :${FINAL_DLM_PORT}"
echo "    AI:       :${FINAL_AI_PORT}"
echo ""

# ==============================================================================
# STEP 5: 실행
# ==============================================================================
echo ""
log "=== STEP 5/5: DLM 실행 ==="

cd "$INSTALL_DIR"

docker compose --env-file .env.hanson -f docker-compose.hanson.yml down 2>/dev/null || true
docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d

log "컨테이너 시작 대기 중..."
sleep 10

echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm"

# 헬스체크 — 호스트에서 외부 포트 확인 (컨테이너 내부 쉘/bash/curl 미사용 정책)
echo ""
HC_PORT="${FINAL_DLM_PORT:-8082}"
log "애플리케이션 포트 LISTEN 대기... (${HC_PORT}, 최대 45초)"
HC_OK=0
for i in $(seq 1 15); do
    # 호스트 기준 TCP LISTEN 체크 (nc 우선, curl 대체)
    if command -v nc &>/dev/null; then
        nc -z -w 2 127.0.0.1 "$HC_PORT" 2>/dev/null && HC_OK=1 && break
    elif command -v curl &>/dev/null; then
        curl -fs -o /dev/null -m 2 "http://127.0.0.1:${HC_PORT}/" && HC_OK=1 && break
    elif command -v ss &>/dev/null; then
        ss -ltn 2>/dev/null | grep -q ":${HC_PORT} " && HC_OK=1 && break
    else
        warn "nc / curl / ss 모두 없어 포트 확인 생략"
        break
    fi
    echo -n "."
    sleep 3
done
echo ""
if [ "$HC_OK" = "1" ]; then
    log "DLM 포트 LISTEN 확인 (127.0.0.1:${HC_PORT})"
else
    warn "45초 이내 포트 LISTEN 미확인 — docker logs dlm-app 로 상태 확인하세요"
fi

# --- 결과 ---
DLM_STATUS=$(docker inspect -f '{{.State.Status}}' dlm-app 2>/dev/null || echo "not found")
AI_STATUS=$(docker inspect -f '{{.State.Status}}' dlm-privacy-ai 2>/dev/null || echo "not found")
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "서버IP")

echo ""
echo "=============================================="
echo "  배포 완료"
echo "=============================================="
echo ""
echo -e "  MariaDB:    ${GREEN}${MARIADB_HOST}:${MARIADB_PORT}${NC} (OS 설치형)"
[ "$DLM_STATUS" = "running" ] && echo -e "  DLM:        ${GREEN}Running${NC}" || echo -e "  DLM:        ${RED}${DLM_STATUS}${NC}"
[ "$AI_STATUS"  = "running" ] && echo -e "  Privacy-AI: ${GREEN}Running${NC}" || echo -e "  Privacy-AI: ${RED}${AI_STATUS}${NC}"
echo ""
echo "  접속: http://${SERVER_IP}:${FINAL_DLM_PORT:-8082}"
echo "  계정: admin / admin1234"
echo ""
echo "  관리 명령어:"
echo "    시작:    cd $INSTALL_DIR && docker compose --env-file .env.hanson -f docker-compose.hanson.yml up -d"
echo "    중지:    cd $INSTALL_DIR && docker compose --env-file .env.hanson -f docker-compose.hanson.yml down"
echo "    재시작:  cd $INSTALL_DIR && docker compose --env-file .env.hanson -f docker-compose.hanson.yml restart"
echo "    로그:    docker logs -f dlm-app"
echo "    상태:    docker ps"
echo ""
