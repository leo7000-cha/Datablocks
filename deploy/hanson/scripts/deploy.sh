#!/bin/bash
# ==============================================================================
# DLM 배포 스크립트 — 한국손사
# 사전 조건: Docker 설치 완료, MariaDB 컨테이너 이미 운영 중
# ==============================================================================
set -euo pipefail

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
echo "  DLM 배포 — 한국손사"
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
MARIADB_CONTAINER="${MARIADB_CONTAINER:-mariadb}"

# ==============================================================================
# STEP 1: 기존 MariaDB 컨테이너 확인
# ==============================================================================
echo ""
log "=== STEP 1/5: 기존 MariaDB 컨테이너 확인 ==="

if ! docker ps --format '{{.Names}}' | grep -qw "$MARIADB_CONTAINER"; then
    err "기존 MariaDB 컨테이너 '$MARIADB_CONTAINER' 가 실행 중이지 않습니다."
    echo ""
    echo "  실행 중인 컨테이너:"
    docker ps --format "  {{.Names}}  ({{.Image}})" || true
    echo ""
    read -p "  MariaDB 컨테이너 이름을 입력하세요: " MARIADB_CONTAINER
    if ! docker ps --format '{{.Names}}' | grep -qw "$MARIADB_CONTAINER"; then
        err "컨테이너 '$MARIADB_CONTAINER' 을(를) 찾을 수 없습니다. 종료합니다."
        exit 1
    fi
fi
log "MariaDB 컨테이너 확인: $MARIADB_CONTAINER (Running)"

# MariaDB 컨테이너 내부 포트 확인
MARIADB_PORT=$(docker inspect "$MARIADB_CONTAINER" \
    --format '{{range $p,$conf := .Config.ExposedPorts}}{{$p}}{{end}}' 2>/dev/null \
    | grep -oP '\d+' | head -1)
MARIADB_PORT="${MARIADB_PORT:-3306}"
log "MariaDB 내부 포트: $MARIADB_PORT"

# ==============================================================================
# STEP 2: Docker 네트워크 구성 (기존 mariadb 연결)
# ==============================================================================
echo ""
log "=== STEP 2/5: Docker 네트워크 구성 ==="

# dlm-network 생성 (이미 존재하면 무시)
if ! docker network ls --format '{{.Name}}' | grep -qw "dlm-network"; then
    docker network create dlm-network
    log "dlm-network 생성 완료"
else
    log "dlm-network 이미 존재"
fi

# 기존 mariadb 컨테이너를 dlm-network 에 연결 (이미 연결되어 있으면 무시)
if docker inspect "$MARIADB_CONTAINER" --format '{{json .NetworkSettings.Networks}}' \
    | grep -q '"dlm-network"'; then
    log "$MARIADB_CONTAINER → dlm-network 이미 연결됨"
else
    docker network connect dlm-network "$MARIADB_CONTAINER"
    log "$MARIADB_CONTAINER → dlm-network 연결 완료"
fi

# ==============================================================================
# STEP 3: Docker 이미지 로드
# ==============================================================================
echo ""
log "=== STEP 3/5: Docker 이미지 로드 ==="

if [ -f "$DEPLOY_ROOT/images/dlm-app.tar.gz" ]; then
    log "DLM 이미지 로드 중... (1~2분)"
    docker load < <(gunzip -c "$DEPLOY_ROOT/images/dlm-app.tar.gz")
    log "DLM 이미지 로드 완료"
else
    err "이미지 파일 없음: images/dlm-app.tar.gz"
    exit 1
fi

if [ -f "$DEPLOY_ROOT/images/dlm-privacy-ai.tar.gz" ]; then
    log "Privacy-AI 이미지 로드 중..."
    docker load < <(gunzip -c "$DEPLOY_ROOT/images/dlm-privacy-ai.tar.gz")
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

# mariadb 컨테이너 이름이 기본(mariadb)이 아닌 경우 env 파일 업데이트
if [ "$MARIADB_CONTAINER" != "mariadb" ]; then
    sed -i "s|^MARIADB_CONTAINER=.*|MARIADB_CONTAINER=${MARIADB_CONTAINER}|g" "$ENV_FILE"
    # JDBC URL & Privacy-AI DB 호스트도 컨테이너명으로 변경
    sed -i "s|mariadb://mariadb:|mariadb://${MARIADB_CONTAINER}:|g" "$ENV_FILE"
    sed -i "s|^PRIVACY_AI_DB_HOST=.*|PRIVACY_AI_DB_HOST=${MARIADB_CONTAINER}|g" "$ENV_FILE"
    log "MariaDB 호스트명 → ${MARIADB_CONTAINER}"
fi

# MariaDB 포트가 3306이 아닌 경우
if [ "$MARIADB_PORT" != "3306" ]; then
    sed -i "s|:3306/cotdl|:${MARIADB_PORT}/cotdl|g" "$ENV_FILE"
    sed -i "s|^PRIVACY_AI_DB_PORT=.*|PRIVACY_AI_DB_PORT=${MARIADB_PORT}|g" "$ENV_FILE"
    log "MariaDB 포트 → ${MARIADB_PORT}"
fi

echo ""
echo "  현재 설정:"
echo "    MariaDB: ${MARIADB_CONTAINER}:${MARIADB_PORT} (기존 컨테이너)"
echo "    DLM 포트: $(grep '^DLM_PORT=' "$ENV_FILE" | cut -d= -f2)"
echo "    AI  포트: $(grep '^AI_PORT=' "$ENV_FILE" | cut -d= -f2)"
echo ""

# --- 인터랙티브 설정 변경 ---
read -p "  DB 비밀번호 변경 [Enter=건너뛰기]: " DB_PASS
if [ -n "$DB_PASS" ]; then
    sed -i "s|^PRIVACY_AI_DB_PASSWORD=.*|PRIVACY_AI_DB_PASSWORD=${DB_PASS}|g" "$ENV_FILE"
    log "DB 비밀번호 변경됨"
fi

read -p "  DLM 포트 변경 [Enter=8082 유지]: " NEW_DLM_PORT
if [ -n "$NEW_DLM_PORT" ]; then
    sed -i "s|^DLM_PORT=.*|DLM_PORT=${NEW_DLM_PORT}|g" "$ENV_FILE"
    log "DLM 포트 → ${NEW_DLM_PORT}"
fi

read -p "  Privacy-AI 포트 변경 [Enter=8000 유지]: " NEW_AI_PORT
if [ -n "$NEW_AI_PORT" ]; then
    sed -i "s|^AI_PORT=.*|AI_PORT=${NEW_AI_PORT}|g" "$ENV_FILE"
    log "AI 포트 → ${NEW_AI_PORT}"
fi

# ==============================================================================
# STEP 5: 실행
# ==============================================================================
echo ""
log "=== STEP 5/5: DLM 실행 ==="

cd "$INSTALL_DIR"
docker compose -f docker-compose.hanson.yml down 2>/dev/null || true
docker compose -f docker-compose.hanson.yml up -d

log "컨테이너 시작 대기 중..."
sleep 10

echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm|$MARIADB_CONTAINER"

# 헬스체크
echo ""
FINAL_PORT=$(grep '^DLM_PORT=' "$ENV_FILE" | cut -d= -f2)
log "애플리케이션 시작 대기... (최대 120초)"
for i in $(seq 1 24); do
    if docker exec dlm-app wget -qO- --timeout=3 http://localhost:8080/ &>/dev/null; then
        echo ""
        log "DLM 정상 시작!"
        break
    fi
    echo -n "."
    sleep 5
done
echo ""

# --- 결과 ---
DLM_STATUS=$(docker inspect -f '{{.State.Status}}' dlm-app 2>/dev/null || echo "not found")
AI_STATUS=$(docker inspect -f '{{.State.Status}}' dlm-privacy-ai 2>/dev/null || echo "not found")
DB_STATUS=$(docker inspect -f '{{.State.Status}}' "$MARIADB_CONTAINER" 2>/dev/null || echo "not found")
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "서버IP")

echo ""
echo "=============================================="
echo "  배포 완료"
echo "=============================================="
echo ""
[ "$DB_STATUS"  = "running" ] && echo -e "  MariaDB:    ${GREEN}Running${NC} (기존 컨테이너: $MARIADB_CONTAINER)" || echo -e "  MariaDB:    ${RED}${DB_STATUS}${NC}"
[ "$DLM_STATUS" = "running" ] && echo -e "  DLM:        ${GREEN}Running${NC}" || echo -e "  DLM:        ${RED}${DLM_STATUS}${NC}"
[ "$AI_STATUS"  = "running" ] && echo -e "  Privacy-AI: ${GREEN}Running${NC}" || echo -e "  Privacy-AI: ${RED}${AI_STATUS}${NC}"
echo ""
echo "  접속: http://${SERVER_IP}:${FINAL_PORT:-8082}"
echo "  계정: admin / admin1234"
echo ""
echo "  관리 명령어:"
echo "    시작:    cd $INSTALL_DIR && docker compose -f docker-compose.hanson.yml up -d"
echo "    중지:    cd $INSTALL_DIR && docker compose -f docker-compose.hanson.yml down"
echo "    로그:    docker logs -f dlm-app"
echo "    상태:    docker ps"
echo ""
