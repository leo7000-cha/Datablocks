#!/bin/bash
# ==============================================================================
# Docker 오프라인 설치 스크립트 — iM캐피탈 (CentOS 7.9)
# 필요 권한: root 또는 sudo
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[!!]${NC} $*"; }
err()  { echo -e "${RED}[ERR]${NC} $*"; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
    err "root 권한이 필요합니다. sudo bash $0 으로 실행하세요."
fi

echo ""
echo "=============================================="
echo "  Docker 오프라인 설치 — iM캐피탈 (CentOS 7)"
echo "=============================================="
echo ""

# --- 기존 Docker 확인 ---
if command -v docker &>/dev/null; then
    warn "Docker가 이미 설치되어 있습니다: $(docker --version)"
    read -p "  계속 진행하시겠습니까? [y/N]: " CONTINUE
    if [ "${CONTINUE,,}" != "y" ]; then
        echo "  설치를 취소합니다."
        exit 0
    fi
fi

# --- RPM 파일 확인 ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RPM_DIR="${SCRIPT_DIR}/../docker-rpms"

if [ ! -d "$RPM_DIR" ] || [ -z "$(ls "$RPM_DIR"/*.rpm 2>/dev/null)" ]; then
    err "Docker RPM 패키지를 찾을 수 없습니다: $RPM_DIR"
fi

echo "  RPM 패키지:"
ls -1 "$RPM_DIR"/*.rpm | while read f; do echo "    - $(basename "$f")"; done
echo ""

# --- 기존 Docker/Podman 제거 ---
log "기존 Docker/Podman 제거 (있는 경우)..."
yum remove -y docker docker-client docker-common docker-engine docker-latest \
    docker-latest-logrotate docker-logrotate podman buildah 2>/dev/null || true

# --- 설치 ---
log "Docker RPM 설치 중..."
yum install -y "$RPM_DIR"/*.rpm 2>/dev/null || {
    warn "yum install 실패, rpm으로 직접 설치 시도..."
    rpm -Uvh --force "$RPM_DIR"/containerd.io-*.rpm 2>/dev/null || true
    rpm -Uvh --force "$RPM_DIR"/docker-ce-cli-*.rpm 2>/dev/null || true
    rpm -Uvh --force "$RPM_DIR"/docker-ce-2*.rpm 2>/dev/null || true
    rpm -Uvh --force "$RPM_DIR"/docker-compose-plugin-*.rpm 2>/dev/null || true
}

# --- Docker 서비스 시작 ---
log "Docker 서비스 시작..."
systemctl start docker
systemctl enable docker

# --- Docker 그룹 ---
SUDO_USER_NAME="${SUDO_USER:-}"
if [ -n "$SUDO_USER_NAME" ] && [ "$SUDO_USER_NAME" != "root" ]; then
    usermod -aG docker "$SUDO_USER_NAME"
    warn "docker 그룹 적용: 다시 로그인 필요 (또는 newgrp docker)"
fi

# --- 디스크 공간 확인 ---
ROOT_AVAIL=$(df /var/lib/docker --output=avail -BG 2>/dev/null | tail -1 | tr -d ' G')
if [ -n "$ROOT_AVAIL" ] && [ "$ROOT_AVAIL" -lt 30 ]; then
    warn "Docker 저장 경로 여유 공간: ${ROOT_AVAIL}GB (최소 20GB 권장)"
    warn "필요시 /etc/docker/daemon.json 에서 data-root 변경"
fi

# --- 방화벽 설정 ---
if systemctl is-active firewalld &>/dev/null; then
    log "방화벽 포트 오픈 (8080, 8000)..."
    firewall-cmd --permanent --add-port=8080/tcp 2>/dev/null || true
    firewall-cmd --permanent --add-port=8000/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    log "방화벽 포트 오픈 완료"
fi

# --- 확인 ---
echo ""
echo "=============================================="
echo "  Docker 설치 확인"
echo "=============================================="
echo ""

if docker --version &>/dev/null; then
    log "Docker Engine: $(docker --version)"
else
    err "Docker 설치 실패"
fi

if docker compose version &>/dev/null; then
    log "Docker Compose: $(docker compose version)"
else
    warn "Docker Compose 플러그인 확인 필요"
fi

if docker info &>/dev/null; then
    log "Docker 데몬: 정상 실행 중"
else
    err "Docker 데몬이 실행되지 않습니다."
fi

echo ""
log "Docker 설치 완료!"
echo ""
echo "  다음 단계: bash scripts/deploy.sh"
echo ""
