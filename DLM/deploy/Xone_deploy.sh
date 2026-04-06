#!/bin/bash
#=============================================================================
# DLM WAR 업데이트 배포 스크립트
#
# 기존 /datablocks 전용 → 스크립트 위치 기준으로도 실행 가능하도록 개선
# application.properties, logback-local.xml 자동 백업/복원
#
# 사용법:
#   sudo bash Xone_deploy.sh                    ← 자동 탐색
#   sudo bash Xone_deploy.sh /path/to/DLM.war   ← WAR 직접 지정
#
# WAR 파일 탐색 순서:
#   1) 인자로 지정한 경로
#   2) 스크립트와 같은 디렉토리
#   3) /datablocks/DLM.war (기존 경로)
#=============================================================================

set -euo pipefail

# ── 스크립트 위치 감지 ───────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 설정 ────────────────────────────────────────────────────
TOMCAT_SERVICE="tomcat"
TOMCAT_LINK_DIR="/opt/tomcat/latest"
WEBAPPS_DIR="${TOMCAT_LINK_DIR}/webapps"
DLM_DIR="${WEBAPPS_DIR}/DLM"
CLASSES_DIR="${DLM_DIR}/WEB-INF/classes"

# ── WAR 파일 탐색 ───────────────────────────────────────────
WAR_INPUT="${1:-}"
WAR_SOURCE=""

# 1) 인자로 지정
if [ -n "${WAR_INPUT}" ] && [ -f "${WAR_INPUT}" ]; then
    WAR_SOURCE="${WAR_INPUT}"
# 2) 스크립트 디렉토리
elif [ -f "${SCRIPT_DIR}/DLM.war" ]; then
    WAR_SOURCE="${SCRIPT_DIR}/DLM.war"
# 3) /datablocks (기존 경로)
elif [ -f "/datablocks/DLM.war" ]; then
    WAR_SOURCE="/datablocks/DLM.war"
fi

if [ -z "${WAR_SOURCE}" ]; then
    echo "[ERROR] DLM.war 파일을 찾을 수 없습니다."
    echo ""
    echo "  탐색 위치:"
    echo "    1) ${WAR_INPUT:-없음 (인자 미지정)}"
    echo "    2) ${SCRIPT_DIR}/DLM.war"
    echo "    3) /datablocks/DLM.war"
    echo ""
    echo "  사용법: sudo bash $0 /path/to/DLM.war"
    exit 1
fi

echo "============================================="
echo " DLM WAR 업데이트 배포"
echo " 날짜: $(date '+%Y-%m-%d %H:%M:%S')"
echo " WAR:  ${WAR_SOURCE} ($(du -h "${WAR_SOURCE}" | cut -f1))"
echo " 대상: ${DLM_DIR}"
echo "============================================="

# ── DLM 디렉토리 존재 확인 ──────────────────────────────────
if [ ! -d "${DLM_DIR}" ]; then
    echo "[ERROR] DLM 디렉토리가 없습니다: ${DLM_DIR}"
    echo "  최초 배포는 Xone_first_deploy.sh 를 사용하세요."
    exit 1
fi

cd "${DLM_DIR}"

# ── [1] Tomcat 서비스 중지 ──────────────────────────────────
echo ""
echo "[1/7] Tomcat 서비스 중지..."
systemctl stop "${TOMCAT_SERVICE}"
echo "  중지 완료"

# ── [2] 설정 파일 백업 ──────────────────────────────────────
echo ""
echo "[2/7] 설정 파일 백업..."

BACKUP_COUNT=0
for conf_file in "application.properties" "logback-local.xml"; do
    if [ -f "${CLASSES_DIR}/${conf_file}" ]; then
        cp "${CLASSES_DIR}/${conf_file}" "${DLM_DIR}/${conf_file}.backup"
        chmod 776 "${DLM_DIR}/${conf_file}.backup"
        echo "  백업: ${conf_file}"
        BACKUP_COUNT=$((BACKUP_COUNT + 1))
    else
        echo "  [WARN] 없음: ${conf_file} - 건너뜀"
    fi
done
echo "  백업 파일 ${BACKUP_COUNT}개 완료"

# ── [3] 기존 파일 삭제 ──────────────────────────────────────
echo ""
echo "[3/7] 기존 애플리케이션 파일 삭제..."
rm -rf "${DLM_DIR}/resources" "${DLM_DIR}/WEB-INF" "${DLM_DIR}/META-INF" "${DLM_DIR}/DLM.war" || true
echo "  삭제 완료"

# ── [4] 새 WAR 복사 + 해제 ──────────────────────────────────
echo ""
echo "[4/7] 새 DLM.war 복사 및 해제..."
cp "${WAR_SOURCE}" "${DLM_DIR}/DLM.war"
jar xf "${DLM_DIR}/DLM.war"
rm -f "${DLM_DIR}/DLM.war"
echo "  해제 완료 (파일 수: $(find . -type f | wc -l))"

# ── [5] 소유자 및 권한 설정 ─────────────────────────────────
echo ""
echo "[5/7] 소유자 및 권한 설정..."
chown -R tomcat: /opt/tomcat
for conf_file in "logback-local.xml" "application.properties"; do
    if [ -f "${CLASSES_DIR}/${conf_file}" ]; then
        chmod 776 "${CLASSES_DIR}/${conf_file}"
    fi
done
echo "  완료"

# ── [6] 설정 파일 복원 ──────────────────────────────────────
echo ""
echo "[6/7] 설정 파일 복원..."

RESTORE_COUNT=0
for conf_file in "application.properties" "logback-local.xml"; do
    if [ -f "${DLM_DIR}/${conf_file}.backup" ]; then
        cp "${DLM_DIR}/${conf_file}.backup" "${CLASSES_DIR}/${conf_file}"
        echo "  복원: ${conf_file}"
        RESTORE_COUNT=$((RESTORE_COUNT + 1))
    else
        echo "  [WARN] 백업 없음: ${conf_file} - 새 파일 사용"
    fi
done
echo "  복원 ${RESTORE_COUNT}개 완료"

# ── [7] Tomcat 서비스 시작 ──────────────────────────────────
echo ""
echo "[7/7] Tomcat 서비스 시작..."
systemctl start "${TOMCAT_SERVICE}"

echo ""
echo "============================================="
echo " WAR 업데이트 배포 완료!"
echo "============================================="
echo ""
echo " WAR:      ${WAR_SOURCE}"
echo " 설정복원: ${RESTORE_COUNT}개 파일"
echo ""
echo " 로그 확인:"
echo "   tail -f ${TOMCAT_LINK_DIR}/logs/catalina.out"
echo "============================================="
