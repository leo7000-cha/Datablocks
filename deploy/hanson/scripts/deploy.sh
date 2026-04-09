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
# STEP 2: 기존 MariaDB 네트워크 감지 (기존 환경 수정 없음)
# ==============================================================================
echo ""
log "=== STEP 2/5: 기존 MariaDB 네트워크 감지 ==="

# 기존 mariadb 컨테이너가 속한 사용자 정의 네트워크를 찾음
# (default bridge 제외 — bridge 에서는 컨테이너명 DNS 안 됨)
MARIADB_NETWORK=""
for net in $(docker inspect "$MARIADB_CONTAINER" \
    --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}'); do
    # 기본 bridge 는 skip
    if [ "$net" = "bridge" ]; then
        continue
    fi
    MARIADB_NETWORK="$net"
    break
done

if [ -z "$MARIADB_NETWORK" ]; then
    # 사용자 정의 네트워크가 없으면 → 하나 만들고 기존 mariadb 연결
    warn "기존 mariadb 에 사용자 정의 네트워크가 없습니다."
    warn "dlm-network 를 생성하고 기존 mariadb 를 연결합니다."
    MARIADB_NETWORK="dlm-network"
    if ! docker network ls --format '{{.Name}}' | grep -qw "$MARIADB_NETWORK"; then
        docker network create "$MARIADB_NETWORK"
    fi
    docker network connect "$MARIADB_NETWORK" "$MARIADB_CONTAINER" 2>/dev/null || true
    log "fallback: $MARIADB_CONTAINER → $MARIADB_NETWORK 연결"
else
    log "기존 네트워크 감지: $MARIADB_NETWORK (기존 환경 수정 없음)"
fi

export MARIADB_NETWORK

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

# 감지한 네트워크명을 .env 에 기록
if grep -q '^MARIADB_NETWORK=' "$ENV_FILE"; then
    sed -i "s|^MARIADB_NETWORK=.*|MARIADB_NETWORK=${MARIADB_NETWORK}|g" "$ENV_FILE"
else
    echo "" >> "$ENV_FILE"
    echo "# --- 자동 감지된 MariaDB 네트워크 ---" >> "$ENV_FILE"
    echo "MARIADB_NETWORK=${MARIADB_NETWORK}" >> "$ENV_FILE"
fi

# mariadb 컨테이너 이름이 기본(mariadb)이 아닌 경우 env 파일 업데이트
if [ "$MARIADB_CONTAINER" != "mariadb" ]; then
    sed -i "s|^MARIADB_CONTAINER=.*|MARIADB_CONTAINER=${MARIADB_CONTAINER}|g" "$ENV_FILE"
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

FINAL_DLM_PORT=$(grep '^DLM_PORT=' "$ENV_FILE" | cut -d= -f2)
FINAL_AI_PORT=$(grep '^AI_PORT=' "$ENV_FILE" | cut -d= -f2)

echo ""
echo "  현재 설정:"
echo "    MariaDB: ${MARIADB_CONTAINER}:${MARIADB_PORT} (기존 컨테이너)"
echo "    네트워크: ${MARIADB_NETWORK} (기존 네트워크 참여)"
echo "    DLM 포트: ${FINAL_DLM_PORT}"
echo "    AI  포트: ${FINAL_AI_PORT}"
echo ""

read -p "  DLM 포트 변경 [Enter=${FINAL_DLM_PORT} 유지]: " NEW_DLM_PORT
if [ -n "$NEW_DLM_PORT" ]; then
    sed -i "s|^DLM_PORT=.*|DLM_PORT=${NEW_DLM_PORT}|g" "$ENV_FILE"
    log "DLM 포트 → ${NEW_DLM_PORT}"
fi

read -p "  Privacy-AI 포트 변경 [Enter=${FINAL_AI_PORT} 유지]: " NEW_AI_PORT
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

# MARIADB_NETWORK 을 export 해야 docker compose 에서 사용 가능
export MARIADB_NETWORK

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
[ "$DB_STATUS"  = "running" ] && echo -e "  MariaDB:    ${GREEN}Running${NC} (기존: $MARIADB_CONTAINER @ $MARIADB_NETWORK)" || echo -e "  MariaDB:    ${RED}${DB_STATUS}${NC}"
[ "$DLM_STATUS" = "running" ] && echo -e "  DLM:        ${GREEN}Running${NC}" || echo -e "  DLM:        ${RED}${DLM_STATUS}${NC}"
[ "$AI_STATUS"  = "running" ] && echo -e "  Privacy-AI: ${GREEN}Running${NC}" || echo -e "  Privacy-AI: ${RED}${AI_STATUS}${NC}"
echo ""
echo "  접속: http://${SERVER_IP}:${FINAL_PORT:-8082}"
echo "  계정: admin / admin1234"
echo ""
echo "  관리 명령어:"
echo "    시작:    cd $INSTALL_DIR && MARIADB_NETWORK=$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml up -d"
echo "    중지:    cd $INSTALL_DIR && MARIADB_NETWORK=$MARIADB_NETWORK docker compose -f docker-compose.hanson.yml down"
echo "    로그:    docker logs -f dlm-app"
echo "    상태:    docker ps"
echo ""
