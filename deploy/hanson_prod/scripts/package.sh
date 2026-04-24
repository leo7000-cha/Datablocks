#!/bin/bash
# ==============================================================================
# DLM 이미지 패키징 스크립트 — 한국손사 PROD
# 운영자(박기용) 요구 사양:
#   - docker save <image> | gzip > third-party-app_<version>.tar.gz
#   - shasum -a 256 결과를 함께 전달 (sh1 자동비교용)
#   - 컨테이너 내부 비밀·헬스체크 지시어 금지 (이미지 자체가 이미 준수)
#
# 사용법:
#   cd deploy/hanson_prod && bash scripts/package.sh [VERSION]
#   기본 VERSION=1.0.0
# ==============================================================================
set -uo pipefail

VERSION="${1:-1.0.0}"
IMAGE="datablocks-dlm:${VERSION}"
AI_IMAGE="datablocks-dlm-privacy-ai:${VERSION}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEPLOY_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$DEPLOY_ROOT/images"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()  { echo -e "${GREEN}[$(date '+%H:%M:%S')]${NC} $*"; }
warn() { echo -e "${YELLOW}[$(date '+%H:%M:%S')]${NC} $*"; }
err()  { echo -e "${RED}[$(date '+%H:%M:%S')]${NC} $*"; }

mkdir -p "$OUT_DIR"

echo ""
echo "=============================================="
echo "  DLM 이미지 패키징 (PROD 전달용)"
echo "=============================================="
echo ""

# --- 이미지 존재 확인 ---
if ! docker image inspect "$IMAGE" &>/dev/null; then
    err "이미지 없음: $IMAGE"
    err "먼저 docker compose build dlm 실행 후 아래 명령으로 태그:"
    err "  docker tag datablocks-dlm:latest $IMAGE"
    exit 1
fi

log "이미지: $IMAGE"

# --- DLM 이미지 내부 비밀 검증 (이미지 확정 전 최종 확인) ---
log "이미지 내부 비밀 검증..."
LEAK=$(docker run --rm --entrypoint sh "$IMAGE" -c \
    "grep -rlE 'ENC\(|jasypt|!Dlm1234' /app/DLM/WEB-INF/classes/ 2>/dev/null" || true)
if [ -n "$LEAK" ]; then
    err "이미지에 비밀 흔적 발견:"
    echo "$LEAK"
    exit 2
fi
log "이미지 내부 비밀 없음 ✓"

# --- DLM 이미지 저장 ---
DLM_TAR="$OUT_DIR/third-party-app_${VERSION}.tar.gz"
log "DLM 이미지 저장 중... (2~3분 소요)"
docker save "$IMAGE" | gzip > "$DLM_TAR"
DLM_SIZE=$(du -h "$DLM_TAR" | cut -f1)
log "생성 완료: $(basename "$DLM_TAR") ($DLM_SIZE)"

# --- SHA256 체크섬 생성 ---
log "SHA256 체크섬 생성..."
cd "$OUT_DIR"
SHA_CMD=""
if command -v sha256sum &>/dev/null; then
    SHA_CMD="sha256sum"
elif command -v shasum &>/dev/null; then
    SHA_CMD="shasum -a 256"
else
    err "sha256sum / shasum 명령을 찾을 수 없습니다"
    exit 3
fi

$SHA_CMD "third-party-app_${VERSION}.tar.gz" > "third-party-app_${VERSION}.tar.gz.sha256"
cat "third-party-app_${VERSION}.tar.gz.sha256"

# --- Privacy-AI 이미지 (선택) ---
if docker image inspect "$AI_IMAGE" &>/dev/null || docker image inspect "datablocks-dlm-privacy-ai:latest" &>/dev/null; then
    echo ""
    read -p "Privacy-AI 이미지도 패키징? [y/N]: " DO_AI
    if [[ "$DO_AI" =~ ^[Yy]$ ]]; then
        if ! docker image inspect "$AI_IMAGE" &>/dev/null; then
            docker tag datablocks-dlm-privacy-ai:latest "$AI_IMAGE"
        fi
        AI_TAR="$OUT_DIR/third-party-app-ai_${VERSION}.tar.gz"
        log "Privacy-AI 이미지 저장 중..."
        docker save "$AI_IMAGE" | gzip > "$AI_TAR"
        $SHA_CMD "third-party-app-ai_${VERSION}.tar.gz" > "third-party-app-ai_${VERSION}.tar.gz.sha256"
        log "생성 완료: $(basename "$AI_TAR")"
    fi
fi

echo ""
echo "=============================================="
echo "  패키징 완료"
echo "=============================================="
echo ""
ls -la "$OUT_DIR"/third-party-app_* 2>/dev/null
echo ""
log "운영자(박기용)에게 전달할 파일:"
echo "  1. third-party-app_${VERSION}.tar.gz"
echo "  2. third-party-app_${VERSION}.tar.gz.sha256  (무결성 검증용)"
echo "  3. docker-compose.hanson.yml  (JDBC_* 주입 블록 포함)"
echo "  4. .env.hanson  (JDBC_URL/JDBC_USERNAME/JDBC_PASSWORD)"
echo ""
log "운영자 측 검증:"
echo "  sha256sum -c third-party-app_${VERSION}.tar.gz.sha256"
echo "  docker load -i third-party-app_${VERSION}.tar.gz"
echo ""
