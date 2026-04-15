#!/bin/bash
# ============================================
# DLM Agent 설치 스크립트 — iM캐피탈
# 대상: 처리계 WAS 서버
# ============================================

set -e

INSTALL_DIR="/opt/dlm-agent"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "============================================"
echo " DLM Agent 설치"
echo " 설치 경로: ${INSTALL_DIR}"
echo "============================================"

# 1. 설치 디렉토리 생성
echo "[1/4] 설치 디렉토리 생성..."
mkdir -p "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}/failover"

# 2. 파일 복사
echo "[2/4] 파일 복사..."
cp "${SCRIPT_DIR}/dlm-agent-1.0.0.jar" "${INSTALL_DIR}/"
cp "${SCRIPT_DIR}/dlm-agent.properties" "${INSTALL_DIR}/"
chmod 644 "${INSTALL_DIR}/dlm-agent-1.0.0.jar"
chmod 644 "${INSTALL_DIR}/dlm-agent.properties"

# 3. 설정 확인
echo "[3/4] 설정 파일 확인..."
echo ""
echo "  서버 URL  : $(grep 'dlm.server.url=' ${INSTALL_DIR}/dlm-agent.properties | cut -d= -f2)"
echo "  Agent ID  : $(grep 'dlm.agent.id=' ${INSTALL_DIR}/dlm-agent.properties | cut -d= -f2)"
echo "  세션 속성 : $(grep 'dlm.user.session-attr=' ${INSTALL_DIR}/dlm-agent.properties | grep -v '^#' | cut -d= -f2 || echo '(자동 탐지)')"
echo ""

# 4. WAS JVM 옵션 안내
echo "[4/4] WAS JVM 옵션 설정이 필요합니다."
echo ""
echo "  아래 인자를 WAS JVM 옵션에 추가한 후 WAS를 재시작하세요:"
echo ""
echo "  -javaagent:${INSTALL_DIR}/dlm-agent-1.0.0.jar=${INSTALL_DIR}/dlm-agent.properties"
echo ""
echo "  WAS별 설정 위치:"
echo "    Tomcat    → CATALINA_OPTS (setenv.sh)"
echo "    WebLogic  → 관리콘솔 > 서버 > 서버시작 > 인수"
echo "    JEUS      → jeus-jvm-option 또는 WebAdmin > JVM 옵션"
echo ""
echo "============================================"
echo " 설치 완료: ${INSTALL_DIR}"
echo " 다음 단계: WAS JVM 옵션 추가 후 재시작"
echo "============================================"
