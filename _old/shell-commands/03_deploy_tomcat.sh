#!/bin/bash
#=============================================================================
# DLM 배포 스크립트 (고객사 서버 - Ubuntu Linux + MariaDB)
# 한국손해사정 초기 배포용
#
# 기존 Tomcat 설치 표준 절차 기반:
#   - tomcat 전용 사용자 (useradd -m -U -d /opt/tomcat -s /bin/false)
#   - /opt/tomcat/apache-tomcat-9.0.87 + /opt/tomcat/latest symlink
#   - catalina.sh start/stop 방식 systemd 서비스
#   - /dlmlogs, /dlmapilogs 로그 디렉토리
#
# 사전조건:
#   - Ubuntu Linux 설치 완료
#   - MariaDB 설치 완료
#   - 패키징 파일(tar.gz) 전달 완료
#
# 실행: sudo bash 02_deploy_target_server.sh /path/to/dlm_deploy_YYYYMMDD.tar.gz
#=============================================================================

set -euo pipefail

# ── 설정 ──────────────────────────────────────────────────────────
TOMCAT_BASE="/opt/tomcat"
TOMCAT_VERSION="apache-tomcat-9.0.87"
TOMCAT_HOME="${TOMCAT_BASE}/latest"           # symlink -> ${TOMCAT_VERSION}
JAVA_INSTALL="/usr/lib/jvm/java-11-amazon-corretto"
TOMCAT_USER="tomcat"
MARIADB_ROOT_USER="root"
SERVICE_NAME="tomcat"

# ── 인자 확인 ─────────────────────────────────────────────────────
ARCHIVE_PATH="${1:-}"

if [ -z "${ARCHIVE_PATH}" ]; then
    echo "사용법: sudo bash $0 <패키징_아카이브_경로>"
    echo "예시:   sudo bash $0 /tmp/dlm_deploy_20260319.tar.gz"
    exit 1
fi

if [ ! -f "${ARCHIVE_PATH}" ]; then
    echo "[오류] 파일을 찾을 수 없습니다: ${ARCHIVE_PATH}"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "[오류] root 권한으로 실행하세요: sudo bash $0 ${ARCHIVE_PATH}"
    exit 1
fi

echo "============================================="
echo " DLM 고객사 배포 시작"
echo " 날짜: $(date '+%Y-%m-%d %H:%M:%S')"
echo " 대상: 한국손해사정"
echo " 아카이브: ${ARCHIVE_PATH}"
echo "============================================="

#=============================================================================
# STEP 0. 아카이브 해제
#=============================================================================
echo ""
echo "[STEP 0/9] 아카이브 해제..."

WORK_DIR="/tmp/dlm_deploy_work"
rm -rf "${WORK_DIR}"
mkdir -p "${WORK_DIR}"
tar xzf "${ARCHIVE_PATH}" -C "${WORK_DIR}"

# tar 내부 디렉토리명 자동 감지
PACK_DIR=$(find "${WORK_DIR}" -maxdepth 1 -type d -name "dlm_deploy_*" | head -1)
if [ -z "${PACK_DIR}" ]; then
    PACK_DIR="${WORK_DIR}"
fi

echo "   해제 완료: ${PACK_DIR}"

#=============================================================================
# STEP 1. tomcat 전용 시스템 사용자 생성
#=============================================================================
echo ""
echo "[STEP 1/9] tomcat 시스템 사용자 생성..."

if id "${TOMCAT_USER}" &>/dev/null; then
    echo "   사용자 '${TOMCAT_USER}' 이미 존재함 - 건너뜀"
else
    # -m: 홈디렉토리 생성, -U: 동명 그룹 생성, -d: 홈을 /opt/tomcat, -s: 로그인 불가
    useradd -m -U -d "${TOMCAT_BASE}" -s /bin/false "${TOMCAT_USER}"
    echo "   사용자 '${TOMCAT_USER}' 생성 완료"
    echo "   홈: ${TOMCAT_BASE}, 쉘: /bin/false, 그룹: ${TOMCAT_USER}"
fi

#=============================================================================
# STEP 2. Java Corretto 11 설치
#=============================================================================
echo ""
echo "[STEP 2/9] Amazon Corretto 11 설치..."

mkdir -p "${JAVA_INSTALL}"

if [ -d "${PACK_DIR}/java/amazon-corretto-11" ]; then
    rsync -a "${PACK_DIR}/java/amazon-corretto-11/" "${JAVA_INSTALL}/"
    chmod +x "${JAVA_INSTALL}/bin/"*
    echo "   Java 설치 완료: ${JAVA_INSTALL}"
    echo "   Java 버전: $("${JAVA_INSTALL}/bin/java" -version 2>&1 | head -1)"
else
    echo "   [경고] Java 폴더 없음."
    echo "   수동 설치: sudo apt install java-11-amazon-corretto-jdk"
fi

# JAVA_HOME 환경변수 설정 (시스템 전역)
cat > /etc/profile.d/dlm_java.sh << EOF
export JAVA_HOME=${JAVA_INSTALL}
export PATH=\${JAVA_HOME}/bin:\${PATH}
EOF
source /etc/profile.d/dlm_java.sh
echo "   JAVA_HOME 설정 완료: ${JAVA_INSTALL}"

#=============================================================================
# STEP 3. Tomcat 설치 (기존 표준 구조)
#=============================================================================
echo ""
echo "[STEP 3/9] Tomcat 설치..."
echo "   구조: ${TOMCAT_BASE}/${TOMCAT_VERSION} + ${TOMCAT_HOME} (symlink)"

# 패키징에서 Tomcat 구조 확인
if [ -d "${PACK_DIR}/tomcat/${TOMCAT_VERSION}" ]; then
    # 기존 표준 구조 (apache-tomcat-x.x.x 폴더)
    rsync -a "${PACK_DIR}/tomcat/${TOMCAT_VERSION}/" "${TOMCAT_BASE}/${TOMCAT_VERSION}/"
    echo "   ${TOMCAT_VERSION} 복사 완료"
elif [ -d "${PACK_DIR}/tomcat" ]; then
    # 패키징에서 /opt/tomcat 전체를 복사한 경우
    rsync -a "${PACK_DIR}/tomcat/" "${TOMCAT_BASE}/"
    echo "   Tomcat 전체 복사 완료"
fi

# symlink 생성: /opt/tomcat/latest -> /opt/tomcat/apache-tomcat-9.0.87
if [ -d "${TOMCAT_BASE}/${TOMCAT_VERSION}" ]; then
    rm -f "${TOMCAT_HOME}"
    ln -s "${TOMCAT_BASE}/${TOMCAT_VERSION}" "${TOMCAT_HOME}"
    echo "   symlink 생성: ${TOMCAT_HOME} -> ${TOMCAT_BASE}/${TOMCAT_VERSION}"
fi

# 런타임 디렉토리 생성
mkdir -p "${TOMCAT_HOME}/"{logs,temp,work}

echo "   Tomcat 설치 완료: ${TOMCAT_HOME}"

#=============================================================================
# STEP 4. Tomcat 실행 권한 설정
#=============================================================================
echo ""
echo "[STEP 4/9] Tomcat 실행 권한 설정..."

# bin 전체 chmod 755 (root 이외 실행 권한)
chmod 755 "${TOMCAT_HOME}/bin/"*
echo "   chmod 755 ${TOMCAT_HOME}/bin/* 완료"

# sh 파일 실행 권한 확인
sh -c "chmod +x ${TOMCAT_HOME}/bin/*.sh"
echo "   *.sh 실행 권한 확인 완료"

#=============================================================================
# STEP 5. 로그 디렉토리 생성 및 소유권
#=============================================================================
echo ""
echo "[STEP 5/9] 로그 디렉토리 및 소유권 설정..."

# /dlmlogs, /dlmapilogs 생성
mkdir -p /dlmlogs /dlmapilogs
chown -R "${TOMCAT_USER}:${TOMCAT_USER}" /dlmlogs
chown -R "${TOMCAT_USER}:${TOMCAT_USER}" /dlmapilogs
echo "   /dlmlogs -> ${TOMCAT_USER}:${TOMCAT_USER}"
echo "   /dlmapilogs -> ${TOMCAT_USER}:${TOMCAT_USER}"

# /opt/tomcat 전체 소유권
chown -R "${TOMCAT_USER}:${TOMCAT_USER}" "${TOMCAT_BASE}"
echo "   ${TOMCAT_BASE} -> ${TOMCAT_USER}:${TOMCAT_USER}"

#=============================================================================
# STEP 6. sudoers 설정
#=============================================================================
echo ""
echo "[STEP 6/9] tomcat 사용자 sudoers 설정..."

SUDOERS_FILE="/etc/sudoers.d/tomcat"
if [ ! -f "${SUDOERS_FILE}" ]; then
    cat > "${SUDOERS_FILE}" << 'EOF'
# DLM Tomcat 서비스 사용자 권한
tomcat ALL=(ALL) NOPASSWD: ALL
EOF
    chmod 440 "${SUDOERS_FILE}"
    # 문법 검증
    if visudo -cf "${SUDOERS_FILE}" &>/dev/null; then
        echo "   sudoers 설정 완료: ${SUDOERS_FILE}"
    else
        echo "   [경고] sudoers 문법 오류! 수동 확인 필요"
        rm -f "${SUDOERS_FILE}"
    fi
else
    echo "   sudoers 이미 존재함 - 건너뜀"
fi

#=============================================================================
# STEP 7. systemd 서비스 등록
#=============================================================================
echo ""
echo "[STEP 7/9] systemd tomcat.service 등록..."

cat > /etc/systemd/system/${SERVICE_NAME}.service << EOF
# /etc/systemd/system/tomcat.service

[Unit]
Description=X-One Apache Tomcat Service
After=network.target mariadb.service
Wants=mariadb.service

[Service]
Type=forking

User=${TOMCAT_USER}
Group=${TOMCAT_USER}
UMask=0007

Environment=JAVA_HOME=${JAVA_INSTALL}
Environment=CATALINA_HOME=${TOMCAT_HOME}
Environment=CATALINA_BASE=${TOMCAT_HOME}
Environment=CATALINA_PID=${TOMCAT_HOME}/temp/tomcat.pid

Environment="CATALINA_OPTS=-Xms4096M -Xmx22464M -server -XX:+UseParallelGC"
Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom -Dspring.profiles.active=prod"

PIDFile=${TOMCAT_HOME}/temp/tomcat.pid

ExecStart=${TOMCAT_HOME}/bin/catalina.sh start
ExecStop=${TOMCAT_HOME}/bin/catalina.sh stop

SuccessExitStatus=143
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ${SERVICE_NAME}.service

echo "   서비스 등록 완료: ${SERVICE_NAME}.service"
echo "   - User: ${TOMCAT_USER}"
echo "   - JAVA_HOME: ${JAVA_INSTALL}"
echo "   - CATALINA_HOME: ${TOMCAT_HOME}"
echo "   - JVM: -Xms4096M -Xmx22464M -server -XX:+UseParallelGC"
echo "   - Profile: prod"
echo "   - PID: ${TOMCAT_HOME}/temp/tomcat.pid"
echo "   - 자동시작: enabled"

#=============================================================================
# STEP 8. 방화벽 설정 (ufw)
#=============================================================================
echo ""
echo "[STEP 9/9] 방화벽 설정..."

if command -v ufw &>/dev/null; then
    ufw allow 8080/tcp comment "DLM Tomcat" 2>/dev/null || true
    echo "   UFW: 8080/tcp 허용"
else
    echo "   UFW 미설치 - 수동 확인:"
    echo "   sudo iptables -A INPUT -p tcp --dport 8080 -j ACCEPT"
fi

# MariaDB 포트 (localhost만 사용하면 불필요, 외부 접속 필요시)
echo "   ※ MariaDB 3306 포트는 localhost 접속이므로 별도 방화벽 불필요"
echo "   ※ 외부 DB 접속 필요시: sudo ufw allow 3306/tcp"

#=============================================================================
# 최종 검증
#=============================================================================
echo ""
echo "============================================="
echo " 배포 완료! 검증 시작..."
echo "============================================="

echo ""
echo "── Java 검증 ──"
"${JAVA_INSTALL}/bin/java" -version 2>&1 || echo "   [경고] Java 검증 실패"

echo ""
echo "── Tomcat 검증 ──"
echo "   symlink: $(ls -la "${TOMCAT_HOME}" 2>/dev/null || echo '없음')"
if [ -f "${TOMCAT_HOME}/bin/catalina.sh" ]; then
    echo "   catalina.sh: OK"
else
    echo "   [경고] catalina.sh 없음!"
fi
ls -la "${TOMCAT_HOME}/webapps/"*.war 2>/dev/null || echo "   [경고] WAR 파일 없음 - webapps 확인 필요"

echo ""
echo "── 소유권 검증 ──"
echo "   /opt/tomcat: $(stat -c '%U:%G' "${TOMCAT_BASE}" 2>/dev/null)"
echo "   /dlmlogs:    $(stat -c '%U:%G' /dlmlogs 2>/dev/null)"
echo "   /dlmapilogs: $(stat -c '%U:%G' /dlmapilogs 2>/dev/null)"

echo ""
echo "── sudoers 검증 ──"
if [ -f "/etc/sudoers.d/tomcat" ]; then
    echo "   /etc/sudoers.d/tomcat: OK"
else
    echo "   [경고] sudoers 설정 없음"
fi

echo ""
echo "============================================="
echo " 배포 결과 요약"
echo "============================================="
echo ""
echo " ┌──────────────────────────────────────────────────────┐"
echo " │ 항목           │ 경로/값                             │"
echo " ├──────────────────────────────────────────────────────┤"
echo " │ Java           │ ${JAVA_INSTALL}                     │"
echo " │ Tomcat Home    │ ${TOMCAT_HOME} (symlink)            │"
echo " │ Tomcat 실제    │ ${TOMCAT_BASE}/${TOMCAT_VERSION}    │"
echo " │ WAR 위치       │ ${TOMCAT_HOME}/webapps/             │"
echo " │ DB             │ MariaDB cotdl                       │"
echo " │ 서비스 사용자  │ ${TOMCAT_USER}                      │"
echo " │ 서비스명       │ ${SERVICE_NAME}.service              │"
echo " │ DLM 로그       │ /dlmlogs                            │"
echo " │ API 로그       │ /dlmapilogs                         │"
echo " │ JVM 메모리     │ -Xms4096M -Xmx22464M               │"
echo " │ Profile        │ prod                                │"
echo " └──────────────────────────────────────────────────────┘"
echo ""
echo " 서비스 관리:"
echo "   시작:     sudo systemctl start ${SERVICE_NAME}"
echo "   중지:     sudo systemctl stop ${SERVICE_NAME}"
echo "   재시작:   sudo systemctl restart ${SERVICE_NAME}"
echo "   상태:     sudo systemctl status ${SERVICE_NAME}"
echo "   로그:     sudo journalctl -u ${SERVICE_NAME} -f"
echo "             tail -f ${TOMCAT_HOME}/logs/catalina.out"
echo "   자동시작: sudo systemctl enable ${SERVICE_NAME}   (이미 설정됨)"
echo "   자동해제: sudo systemctl disable ${SERVICE_NAME}"
echo ""
echo " 접속 URL: http://<서버IP>:8080"
echo ""
echo " ============================================="
echo " ★ 다음 단계 ★"
echo " ============================================="
echo ""
echo "   sudo systemctl start ${SERVICE_NAME}"
echo "   http://<서버IP>:8080 접속 확인"
echo ""
echo " ※ 02_deploy_mariadb.sh 가 먼저 완료되었는지 확인하세요!"
echo "   DB가 올라와야 Tomcat이 정상 시작됩니다."
echo ""
echo " ※ 주의사항:"
echo "   2. application.properties DB 접속정보 확인 (Jasypt 키 동일해야 함)"
echo "   3. spring.profiles.active=prod (systemd JAVA_OPTS에 설정됨)"
echo "   4. logback-prod.xml 로그 경로가 /dlmlogs, /dlmapilogs 인지 확인"
echo "   5. 고객사 서버 메모리가 JVM 22G 설정에 충분한지 확인"
echo "      부족하면 /etc/systemd/system/tomcat.service 에서 CATALINA_OPTS 수정"
echo "============================================="

# 임시 파일 정리
rm -rf "${WORK_DIR}"
echo ""
echo "임시 파일 정리 완료."
echo ""
echo ">> 다음: sudo systemctl start ${SERVICE_NAME}"
