#!/bin/bash
# ==============================================================================
# DLM 배포 스크립트 — JB우리캐피탈
# 환경: Rocky 9, MariaDB 호스트 OS 직접 설치
# ==============================================================================
set -uo pipefail
# ★ set -e 제거: docker/mysql 명령 실패 시 스크립트 중단 방지

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
COMPOSE_FILE="docker-compose.jbwoori.yml"
ENV_FILE=".env.jbwoori"

echo ""
echo "=============================================="
echo "  DLM 배포 — JB우리캐피탈"
echo "  MariaDB: 호스트 OS 직접 설치"
echo "=============================================="
echo ""

# ==============================================================================
# 사전 확인
# ==============================================================================
if ! docker info &>/dev/null; then
    err "Docker가 실행 중이지 않습니다."
    echo "  먼저 실행: sudo bash scripts/install-docker.sh"
    exit 1
fi
log "Docker: $(docker --version)"

# --- MariaDB 실행 확인 ---
if systemctl is-active --quiet mariadb 2>/dev/null; then
    log "MariaDB: 실행 중 (systemd)"
elif systemctl is-active --quiet mysql 2>/dev/null; then
    log "MariaDB: 실행 중 (mysql 서비스명)"
elif ss -tlnp 2>/dev/null | grep -q ':3306'; then
    log "MariaDB: 포트 3306 리스닝 확인 (ss)"
elif netstat -tlnp 2>/dev/null | grep -q ':3306'; then
    log "MariaDB: 포트 3306 리스닝 확인 (netstat)"
else
    warn "MariaDB가 실행 중이지 않은 것 같습니다."
    warn "  확인: sudo systemctl status mariadb"
    read -p "  계속 진행하시겠습니까? (y/N): " CONTINUE
    [ "$CONTINUE" != "y" ] && exit 1
fi

# --- 8443 포트 충돌 확인 (기존 Tomcat 등) ---
if ss -tlnp 2>/dev/null | grep -q ':8443 ' || netstat -tlnp 2>/dev/null | grep -q ':8443 '; then
    warn "포트 8443 이 이미 사용 중입니다. (기존 Tomcat 등)"
    warn "  기존 서비스 중지 필요:"
    warn "    sudo systemctl stop tomcat   (또는 해당 서비스명)"
    warn "    또는 .env.jbwoori 의 DLM_PORT_HTTPS 를 다른 포트로 변경"
    echo ""
    read -p "  계속 진행하시겠습니까? (y/N): " CONTINUE
    [ "$CONTINUE" != "y" ] && exit 1
fi

# --- MariaDB bind-address 확인 ---
BIND_CHECK=$(mysql -u root -e "SHOW VARIABLES LIKE 'bind_address';" 2>/dev/null \
    || mysql -u root -p'!Dlm1234' -e "SHOW VARIABLES LIKE 'bind_address';" 2>/dev/null \
    || echo "")
BIND_CHECK=$(echo "$BIND_CHECK" | grep -i bind || true)
if echo "$BIND_CHECK" | grep -q "127.0.0.1"; then
    warn "MariaDB bind-address가 127.0.0.1입니다."
    warn "  Docker 컨테이너에서 접속하려면 0.0.0.0 으로 변경 필요:"
    warn "  /etc/my.cnf.d/ 에 설정 추가: [mysqld] bind-address = 0.0.0.0"
    warn "  변경 후: sudo systemctl restart mariadb"
    echo ""
    read -p "  계속 진행하시겠습니까? (y/N): " CONTINUE
    [ "$CONTINUE" != "y" ] && exit 1
fi

# ==============================================================================
# STEP 1: Docker 이미지 로드
# ==============================================================================
echo ""
log "=== STEP 1/3: Docker 이미지 로드 ==="

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
# STEP 2: 설정 파일 배치
# ==============================================================================
echo ""
log "=== STEP 2/3: 설정 파일 배치 ==="

mkdir -p "$INSTALL_DIR"
cp "$DEPLOY_ROOT/$COMPOSE_FILE" "$INSTALL_DIR/"
cp "$DEPLOY_ROOT/$ENV_FILE" "$INSTALL_DIR/"

# --- HTTPS 인증서 복사 (./certs 상대경로 마운트 → 같은 디렉토리에 위치 필요) ---
mkdir -p "$INSTALL_DIR/certs"
if [ -f "$DEPLOY_ROOT/certs/dlm-keystore.p12" ]; then
    cp "$DEPLOY_ROOT/certs/dlm-keystore.p12" "$INSTALL_DIR/certs/"
    chmod 600 "$INSTALL_DIR/certs/dlm-keystore.p12"
    log "HTTPS 인증서 복사 완료: $INSTALL_DIR/certs/dlm-keystore.p12"
else
    err "HTTPS 인증서 없음: certs/dlm-keystore.p12"
    err "  배포 패키지에 인증서가 누락되었습니다. 패키지 재수령 필요."
    exit 1
fi

log "파일 복사 완료: $INSTALL_DIR"

TARGET_ENV="$INSTALL_DIR/$ENV_FILE"

echo ""
echo "  현재 설정:"
echo "    DB Host: host.docker.internal (= 이 서버의 MariaDB)"
echo "    DLM 포트: HTTPS $(grep '^DLM_PORT_HTTPS=' "$TARGET_ENV" | cut -d= -f2) (메인) + HTTP $(grep '^DLM_PORT=' "$TARGET_ENV" | cut -d= -f2) (리다이렉트)"
echo "    AI 포트: $(grep '^AI_PORT=' "$TARGET_ENV" | cut -d= -f2)"
echo ""

# --- MariaDB 포트 변경 ---
read -p "  MariaDB 포트 [Enter=3306 유지]: " DB_PORT
if [ -n "$DB_PORT" ]; then
    sed -i "s|:3306/cotdl|:${DB_PORT}/cotdl|g" "$TARGET_ENV"
    sed -i "s|^PRIVACY_AI_DB_PORT=.*|PRIVACY_AI_DB_PORT=${DB_PORT}|g" "$TARGET_ENV"
    log "DB 포트 → ${DB_PORT}"
fi

# --- DB 비밀번호 변경 ---
read -p "  DB 비밀번호 [Enter=기본값 유지]: " DB_PASS
if [ -n "$DB_PASS" ]; then
    sed -i "s|^PRIVACY_AI_DB_PASSWORD=.*|PRIVACY_AI_DB_PASSWORD=${DB_PASS}|g" "$TARGET_ENV"
    log "DB 비밀번호 변경됨"
fi

# --- DLM HTTP 포트 변경 (리다이렉트용) ---
read -p "  DLM HTTP 포트 [Enter=8080 유지]: " DLM_PORT_INPUT
if [ -n "$DLM_PORT_INPUT" ]; then
    sed -i "s|^DLM_PORT=.*|DLM_PORT=${DLM_PORT_INPUT}|g" "$TARGET_ENV"
    log "DLM HTTP 포트 → ${DLM_PORT_INPUT}"
fi

# --- DLM HTTPS 포트 변경 (메인) ---
read -p "  DLM HTTPS 포트 [Enter=8443 유지]: " DLM_HTTPS_INPUT
if [ -n "$DLM_HTTPS_INPUT" ]; then
    sed -i "s|^DLM_PORT_HTTPS=.*|DLM_PORT_HTTPS=${DLM_HTTPS_INPUT}|g" "$TARGET_ENV"
    log "DLM HTTPS 포트 → ${DLM_HTTPS_INPUT}"
fi

# --- AI 포트 변경 ---
read -p "  Privacy-AI 포트 [Enter=8000 유지]: " AI_PORT_INPUT
if [ -n "$AI_PORT_INPUT" ]; then
    sed -i "s|^AI_PORT=.*|AI_PORT=${AI_PORT_INPUT}|g" "$TARGET_ENV"
    log "AI 포트 → ${AI_PORT_INPUT}"
fi

# ==============================================================================
# STEP 3: 실행
# ==============================================================================
echo ""
log "=== STEP 3/3: DLM 실행 ==="

cd "$INSTALL_DIR"
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" down 2>/dev/null || true
docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d

log "컨테이너 시작 대기 중..."
sleep 10

echo ""
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAME|dlm"

# --- DB 연결 테스트 ---
echo ""
log "호스트 MariaDB 연결 테스트..."
if docker exec dlm-app sh -c 'cat < /dev/tcp/host.docker.internal/3306' &>/dev/null; then
    log "MariaDB 연결: 성공"
else
    warn "MariaDB 연결 실패 — bind-address 또는 방화벽 확인 필요"
    warn "  firewall-cmd --add-port=3306/tcp --permanent && firewall-cmd --reload"
fi

echo ""
log "애플리케이션 시작 대기... (최대 120초)"
for i in $(seq 1 24); do
    if docker exec dlm-app wget -qO- --timeout=3 --no-check-certificate https://localhost:8443/ &>/dev/null; then
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
FINAL_HTTP_PORT=$(grep '^DLM_PORT=' "$TARGET_ENV" | cut -d= -f2)
FINAL_HTTPS_PORT=$(grep '^DLM_PORT_HTTPS=' "$TARGET_ENV" | cut -d= -f2)

echo ""
echo "=============================================="
echo "  배포 완료"
echo "=============================================="
echo ""
[ "$DLM_STATUS" = "running" ] && echo -e "  DLM:        ${GREEN}Running${NC}" || echo -e "  DLM:        ${RED}${DLM_STATUS}${NC}"
[ "$AI_STATUS" = "running" ] && echo -e "  Privacy-AI: ${GREEN}Running${NC}" || echo -e "  Privacy-AI: ${RED}${AI_STATUS}${NC}"
echo ""
echo "  접속: https://${SERVER_IP}:${FINAL_HTTPS_PORT:-8443}"
echo "         (http://${SERVER_IP}:${FINAL_HTTP_PORT:-8080} → 자동 리다이렉트)"
echo "  계정: admin / admin1234"
echo ""
echo "  ★ 자체 서명 인증서 안내:"
echo "    브라우저 첫 접속 시 '안전하지 않음' 경고 → '고급 → 진행' 으로 통과"
echo "    운영 인증서 교체: certs/dlm-keystore.p12 교체 후 dlm 컨테이너 재시작"
echo ""
echo "  ★ tbl_piidatabase 설정:"
echo "    hostname = host.docker.internal"
echo "    (컨테이너에서 호스트 OS의 MariaDB에 접속하는 주소)"
echo ""
echo "  관리 명령어:"
echo "    시작:    cd $INSTALL_DIR && docker compose --env-file $ENV_FILE -f $COMPOSE_FILE up -d"
echo "    중지:    cd $INSTALL_DIR && docker compose --env-file $ENV_FILE -f $COMPOSE_FILE down"
echo "    로그:    docker logs -f dlm-app"
echo "    상태:    docker ps"
echo ""
