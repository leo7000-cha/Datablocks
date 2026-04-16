#!/bin/bash
# ==============================================================================
# Docker 오프라인 설치 스크립트 — iM캐피탈 (CentOS 7.9)
# 필요 권한: root 또는 sudo
# ==============================================================================
set -uo pipefail
# ★ set -e 제거: rpm 명령이 이미 설치된 패키지에서 비정상 코드 반환 → 스크립트 중단 방지

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

# --- 기존 Docker/Podman 완전 제거 (이전 설치 실패 흔적 포함) ---
log "기존 Docker/Podman 완전 제거 (있는 경우)..."
systemctl stop docker 2>/dev/null || true
systemctl stop containerd 2>/dev/null || true
yum --disablerepo="*" remove -y docker docker-client docker-common docker-engine docker-latest \
    docker-latest-logrotate docker-logrotate podman buildah \
    docker-ce docker-ce-cli containerd.io docker-compose-plugin \
    container-selinux 2>/dev/null || true
# 반쯤 설치된 RPM 강제 제거
for pkg in docker-ce docker-ce-cli containerd.io docker-compose-plugin container-selinux; do
    rpm -e --noscripts "$pkg" 2>/dev/null || true
done
log "기존 패키지 제거 완료"

# --- 의존성 + Docker 설치 (CentOS 7 minimal 대응) ---
# 설치 순서: 의존성 → container-selinux → containerd → cli → ce → compose
log "RPM 설치 중 (의존성 포함 14개)..."

# STEP 1: 기본 의존성 (CentOS 7 minimal에 없을 수 있는 패키지 전부)
for pkg in gzip tar xz which iproute net-tools iptables \
           libseccomp libcgroup libtool-ltdl audit-libs-python checkpolicy \
           python-IPy setools-libs libsemanage-python policycoreutils-python; do
    if ls "$RPM_DIR"/${pkg}-*.rpm &>/dev/null; then
        rpm -q "$pkg" &>/dev/null || {
            rpm -Uvh --force --nodeps "$RPM_DIR"/${pkg}-*.rpm 2>/dev/null && \
                log "  $pkg 설치 완료" || warn "  $pkg 설치 실패 (무시)"
        }
    fi
done

# STEP 2: container-selinux (★ 핵심 — 이게 없으면 Docker 설치 실패)
if ls "$RPM_DIR"/container-selinux-*.rpm &>/dev/null; then
    rpm -Uvh --force --nodeps "$RPM_DIR"/container-selinux-*.rpm 2>/dev/null && \
        log "  container-selinux 설치 완료" || warn "  container-selinux 설치 실패"
else
    err "container-selinux RPM이 없습니다. docker-rpms/ 에 넣어주세요."
fi

# STEP 3: Docker (순서 중요: containerd → cli → ce → compose)
log "Docker 엔진 설치..."
rpm -Uvh --force --nodeps "$RPM_DIR"/containerd.io-*.rpm          2>/dev/null && log "  containerd 설치 완료"     || err "containerd 설치 실패"
rpm -Uvh --force --nodeps "$RPM_DIR"/docker-ce-cli-*.rpm          2>/dev/null && log "  docker-ce-cli 설치 완료"  || err "docker-ce-cli 설치 실패"
rpm -Uvh --force --nodeps "$RPM_DIR"/docker-ce-2*.rpm             2>/dev/null && log "  docker-ce 설치 완료"      || err "docker-ce 설치 실패"
rpm -Uvh --force --nodeps "$RPM_DIR"/docker-compose-plugin-*.rpm  2>/dev/null && log "  docker-compose 설치 완료" || warn "docker-compose 설치 실패"

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
    log "방화벽 포트 오픈 (8080, 8000) — firewalld..."
    firewall-cmd --permanent --add-port=8080/tcp 2>/dev/null || true
    firewall-cmd --permanent --add-port=8000/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    log "방화벽 포트 오픈 완료"
elif systemctl is-active iptables &>/dev/null; then
    log "방화벽 포트 오픈 (8080, 8000) — iptables..."
    iptables -I INPUT -p tcp --dport 8080 -j ACCEPT 2>/dev/null || true
    iptables -I INPUT -p tcp --dport 8000 -j ACCEPT 2>/dev/null || true
    service iptables save 2>/dev/null || true
    log "방화벽 포트 오픈 완료"
else
    warn "방화벽 서비스가 감지되지 않습니다. 포트 8080, 8000 접근 가능 여부 확인 필요"
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
