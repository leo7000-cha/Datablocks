#!/bin/bash
# ==============================================================================
# DLM 배포 스크립트 — JB우리캐피탈
# 사전 조건: Docker 설치 완료, MariaDB 설치 완료
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
echo "  DLM 배포 — JB우리캐피탈"
echo "=============================================="
echo ""

# --- 사전 확인 ---
if ! docker info &>/dev/null; then
    err "Docker가 실행 중이지 않습니다."
    echo "  먼저 실행: sudo bash scripts/install-docker.sh"
    exit 1
fi
log "Docker: $(docker --version)"

# ==============================================================================
# STEP 1: Docker 이미지 로드
# ==============================================================================
echo ""
log "=== STEP 1/3: Docker 이미지 로드 ==="

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
# STEP 2: 설정 파일 배치
# ==============================================================================
echo ""
log "=== STEP 2/3: 설정 파일 배치 ==="

mkdir -p "$INSTALL_DIR"
cp "$DEPLOY_ROOT/docker-compose.jbwoori.yml" "$INSTALL_DIR/"
cp "$DEPLOY_ROOT/.env.jbwoori" "$INSTALL_DIR/"
log "파일 복사 완료: $INSTALL_DIR"

ENV_FILE="$INSTALL_DIR/.env.jbwoori"

echo ""
echo "  현재 설정:"
echo "    DB: $(grep '^PRIVACY_AI_DB_HOST=' "$ENV_FILE" | cut -d= -f2)"
echo "    DLM 포트: $(grep '^DLM_PORT=' "$ENV_FILE" | cut -d= -f2)"
echo "    AI 포트: $(grep '^AI_PORT=' "$ENV_FILE" | cut -d= -f2)"
echo ""

read -p "  DB 서버 IP [Enter=건너뛰기]: " DB_IP
if [ -n "$DB_IP" ]; then
    sed -i "s|mariadb://[^:]*:|mariadb://${DB_IP}:|g" "$ENV_FILE"
    sed -i "s|^PRIVACY_AI_DB_HOST=.*|PRIVACY_AI_DB_HOST=${DB_IP}|g" "$ENV_FILE"
    log "DB IP → ${DB_IP}"
fi

read -p "  DB 포트 [Enter=3306 유지]: " DB_PORT
if [ -n "$DB_PORT" ]; then
    sed -i "s|:3306/cotdl|:${DB_PORT}/cotdl|g" "$ENV_FILE"
    sed -i "s|^PRIVACY_AI_DB_PORT=.*|PRIVACY_AI_DB_PORT=${DB_PORT}|g" "$ENV_FILE"
    log "DB 포트 → ${DB_PORT}"
fi

read -p "  DB 비밀번호 (DLM_DATABASE_INIT.sql의 #{DLM_PW} 값): " DB_PASS
if [ -n "$DB_PASS" ]; then
    sed -i "s|^PRIVACY_AI_DB_PASSWORD=.*|PRIVACY_AI_DB_PASSWORD=${DB_PASS}|g" "$ENV_FILE"
    log "DB 비밀번호 변경됨"
fi

read -p "  DLM 포트 [Enter=8080 유지]: " DLM_PORT
if [ -n "$DLM_PORT" ]; then
    sed -i "s|^DLM_PORT=.*|DLM_PORT=${DLM_PORT}|g" "$ENV_FILE"
    log "DLM 포트 → ${DLM_PORT}"
fi

read -p "  Privacy-AI 포트 [Enter=8000 유지]: " AI_PORT
if [ -n "$AI_PORT" ]; then
    sed -i "s|^AI_PORT=.*|AI_PORT=${AI_PORT}|g" "$ENV_FILE"
    log "AI 포트 → ${AI_PORT}"
fi

# ==============================================================================
# STEP 3: 실행
# ==============================================================================
echo ""
log "=== STEP 3/3: DLM 실행 ==="

cd "$INSTALL_DIR"
docker compose -f docker-compose.jbwoori.yml down 2>/dev/null || true
docker compose -f docker-compose.jbwoori.yml up -d

log "컨테이너 시작 대기 중..."
sleep 10

echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm"

echo ""
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
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "서버IP")
FINAL_PORT=$(grep '^DLM_PORT=' "$ENV_FILE" | cut -d= -f2)

echo ""
echo "=============================================="
echo "  배포 완료"
echo "=============================================="
echo ""
[ "$DLM_STATUS" = "running" ] && echo -e "  DLM:        ${GREEN}Running${NC}" || echo -e "  DLM:        ${RED}${DLM_STATUS}${NC}"
[ "$AI_STATUS" = "running" ] && echo -e "  Privacy-AI: ${GREEN}Running${NC}" || echo -e "  Privacy-AI: ${RED}${AI_STATUS}${NC}"
echo ""
echo "  접속: http://${SERVER_IP}:${FINAL_PORT:-8080}"
echo "  계정: admin / admin1234"
echo ""
echo "  관리 명령어:"
echo "    시작:    cd $INSTALL_DIR && docker compose -f docker-compose.jbwoori.yml up -d"
echo "    중지:    cd $INSTALL_DIR && docker compose -f docker-compose.jbwoori.yml down"
echo "    로그:    docker logs -f dlm-app"
echo "    상태:    docker ps"
echo ""
