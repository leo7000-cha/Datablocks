#!/bin/bash
#=============================================================================
# DLM 최초 WAR 배포 스크립트 (SSL + WAR + 설정)
#
# 기존 /datablocks 전용 → 스크립트 위치 기준으로도 실행 가능하도록 개선
#
# 사용법:
#   sudo bash Xone_first_deploy.sh                    ← 자동 탐색
#   sudo bash Xone_first_deploy.sh /path/to/DLM.war   ← WAR 직접 지정
#
# WAR 파일 탐색 순서:
#   1) 인자로 지정한 경로
#   2) 스크립트와 같은 디렉토리
#   3) /datablocks/DLM.war (기존 경로)
#=============================================================================

set -euo pipefail

# ── 스크립트 위치 감지 ───────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Tomcat 경로 (symlink 자동 감지) ─────────────────────────
TOMCAT_LINK_DIR="/opt/tomcat/latest"

if [ -L "${TOMCAT_LINK_DIR}" ]; then
    TOMCAT_REAL=$(readlink -f "${TOMCAT_LINK_DIR}")
    TOMCAT_VERSION_DIR="${TOMCAT_REAL}"
elif [ -d "${TOMCAT_LINK_DIR}" ]; then
    TOMCAT_VERSION_DIR="${TOMCAT_LINK_DIR}"
else
    echo "[ERROR] Tomcat 경로를 찾을 수 없습니다: ${TOMCAT_LINK_DIR}"
    exit 1
fi

WEBAPPS_DIR="${TOMCAT_LINK_DIR}/webapps"
SSL_DIR="${TOMCAT_LINK_DIR}/conf/ssl"
UPLOAD_DIR="${TOMCAT_LINK_DIR}/work/Catalina/localhost/ROOT/upload"

# ── WAR 파일 탐색 ───────────────────────────────────────────
find_file() {
    local filename="$1"
    local explicit_path="${2:-}"

    # 1) 인자로 지정된 경로
    if [ -n "${explicit_path}" ] && [ -f "${explicit_path}" ]; then
        echo "${explicit_path}"; return 0
    fi
    # 2) 스크립트와 같은 디렉토리
    if [ -f "${SCRIPT_DIR}/${filename}" ]; then
        echo "${SCRIPT_DIR}/${filename}"; return 0
    fi
    # 3) /datablocks (기존 경로)
    if [ -f "/datablocks/${filename}" ]; then
        echo "/datablocks/${filename}"; return 0
    fi

    return 1
}

DLM_WAR_SOURCE=$(find_file "DLM.war" "${1:-}") || {
    echo "[ERROR] DLM.war 파일을 찾을 수 없습니다."
    echo "  탐색 위치:"
    echo "    1) ${1:-없음 (인자 미지정)}"
    echo "    2) ${SCRIPT_DIR}/DLM.war"
    echo "    3) /datablocks/DLM.war"
    echo ""
    echo "  사용법: sudo bash $0 /path/to/DLM.war"
    exit 1
}

JKS_SOURCE=$(find_file "harmonix_kr.jks") || {
    echo "[WARN] harmonix_kr.jks 파일을 찾을 수 없습니다. SSL 설정을 건너뜁니다."
    echo "  탐색 위치: ${SCRIPT_DIR}/, /datablocks/"
    JKS_SOURCE=""
}

echo "============================================="
echo " DLM 최초 WAR 배포"
echo " 날짜:   $(date '+%Y-%m-%d %H:%M:%S')"
echo " WAR:    ${DLM_WAR_SOURCE}"
echo " JKS:    ${JKS_SOURCE:-없음}"
echo " Tomcat: ${TOMCAT_VERSION_DIR}"
echo "============================================="

# ---------------------------------
# [1] ssl 디렉토리 생성 및 권한 설정
# ---------------------------------
mkdir -p "$SSL_DIR"
chmod 776 "$SSL_DIR"
echo "[INFO] [1/9] ssl 디렉토리 생성 완료: $SSL_DIR"

# ---------------------------------
# [2] keystore 파일 복사
# ---------------------------------
if [ -n "${JKS_SOURCE}" ]; then
    cp "${JKS_SOURCE}" "$SSL_DIR/"
    echo "[INFO] [2/9] keystore 복사 완료: $SSL_DIR/harmonix_kr.jks"
else
    echo "[SKIP] [2/9] keystore 파일 없음 - SSL 설정 건너뜀"
fi

# ---------------------------------
# [3] upload 디렉토리 생성 및 권한 설정
# ---------------------------------
mkdir -p "$UPLOAD_DIR"
chmod 776 "$UPLOAD_DIR"
echo "[INFO] [3/9] upload 디렉토리 생성 완료: $UPLOAD_DIR"

# ---------------------------------
# [4] 기존 DLM.war 및 DLM 디렉토리 삭제
# ---------------------------------
rm -f "$WEBAPPS_DIR/DLM.war"
rm -rf "$WEBAPPS_DIR/DLM"
echo "[INFO] [4/9] 기존 DLM.war 및 DLM 디렉토리 삭제 완료"

# ---------------------------------
# [5] DLM 디렉토리 생성 및 권한 설정
# ---------------------------------
mkdir -p "$WEBAPPS_DIR/DLM"
chmod 710 "$WEBAPPS_DIR/DLM"
echo "[INFO] [5/9] DLM 디렉토리 생성 완료"

# ---------------------------------
# [6] DLM.war 파일 복사
# ---------------------------------
cp "$DLM_WAR_SOURCE" "$WEBAPPS_DIR/DLM/"
echo "[INFO] [6/9] DLM.war 복사 완료 ($(du -h "$WEBAPPS_DIR/DLM/DLM.war" | cut -f1))"

# ---------------------------------
# [7] WAR 압축 해제
# ---------------------------------
cd "$WEBAPPS_DIR/DLM" || { echo "[ERROR] DLM 디렉토리 이동 실패"; exit 1; }
jar xf DLM.war
rm -f DLM.war
echo "[INFO] [7/9] WAR 압축 해제 완료"
echo "   파일 수: $(find . -type f | wc -l)"

# ---------------------------------
# [8] 설정 파일 권한 부여
# ---------------------------------
CLASSES_DIR="$WEBAPPS_DIR/DLM/WEB-INF/classes"
for conf_file in "logback-local.xml" "application.properties"; do
    if [ -f "$CLASSES_DIR/$conf_file" ]; then
        chmod 776 "$CLASSES_DIR/$conf_file"
        echo "[INFO] [8/9] 권한 설정: $conf_file"
    else
        echo "[WARN] [8/9] 파일 없음: $conf_file"
    fi
done

# ---------------------------------
# [9] Tomcat 전체 소유자 변경
# ---------------------------------
chown -R tomcat: /opt/tomcat
echo "[INFO] [9/9] 소유자 변경 완료: tomcat: /opt/tomcat"

# ---------------------------------
# 결과 요약
# ---------------------------------
echo ""
echo "============================================="
echo " 최초 배포 완료!"
echo "============================================="
echo ""
echo " WAR 위치:  $WEBAPPS_DIR/DLM/"
echo " SSL 위치:  $SSL_DIR/"
echo " 설정 파일: $CLASSES_DIR/application.properties"
echo ""
echo " ※ 필요시 설정 파일 수정:"
echo "   vi $CLASSES_DIR/application.properties"
echo ""
echo " ※ 서비스 시작:"
echo "   sudo systemctl start tomcat"
echo "============================================="
