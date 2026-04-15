#!/bin/bash
#=============================================================================
# DLM 배포 패키징 스크립트 (현재 서버 - Rocky Linux)
# 한국손해사정 초기 배포용
#
# 실행: sudo bash 01_pack_source_server.sh
#=============================================================================

set -euo pipefail

# ── 설정 ──────────────────────────────────────────────────────────
PACK_DIR="/backup/dlm_deploy_$(date +%Y%m%d)"
DB_NAME="cotdl"
MARIADB_USER="root"

# Tomcat 경로 (현재 서버 - symlink 또는 실제 경로)
# /opt/tomcat/latest 가 symlink이면 실제 디렉토리를 따라감
TOMCAT_LATEST="/opt/tomcat/latest"

# Java Corretto 11 경로 (확인 후 수정)
JAVA_HOME_DIR="/usr/lib/jvm/java-11-amazon-corretto"
# JAVA_HOME_DIR="/usr/lib/jvm/java-11-amazon-corretto.x86_64"

# 로그 디렉토리 (고객사에도 동일 생성)
LOG_DIRS=("/dlmlogs" "/dlmapilogs")

#=============================================================================
echo "============================================="
echo " DLM 배포 패키징 시작"
echo " 날짜: $(date '+%Y-%m-%d %H:%M:%S')"
echo " 출력: ${PACK_DIR}"
echo "============================================="

# ── 패키징 디렉토리 생성 ─────────────────────────────────────────
mkdir -p "${PACK_DIR}"/{db,tomcat,java,scripts}

#=============================================================================
# STEP 1. DB 백업
#=============================================================================
echo ""
echo "[STEP 1/6] MariaDB cotdl 데이터베이스 백업..."

mysqldump -u "${MARIADB_USER}" -p \
  --databases "${DB_NAME}" \
  --routines \
  --triggers \
  --events \
  --single-transaction \
  --quick \
  --default-character-set=utf8mb4 \
  > "${PACK_DIR}/db/cotdl_dump.sql"

echo "   DB 덤프 완료: $(du -h "${PACK_DIR}/db/cotdl_dump.sql" | cut -f1)"

#=============================================================================
# STEP 2. 사용자 계정 GRANT 정보 추출
#=============================================================================
echo ""
echo "[STEP 2/6] cotdl 관련 사용자 계정 GRANT 추출..."

GRANT_FILE="${PACK_DIR}/db/cotdl_users.sql"
cat > "${GRANT_FILE}" << 'HEADER'
-- ==========================================================
-- cotdl 사용자 계정 생성 및 권한 부여
-- 생성일: 자동 생성됨
-- 주의: [비밀번호] 부분을 실제 비밀번호로 교체하세요!
-- ==========================================================
HEADER

echo ""
echo "   MariaDB root 비밀번호를 입력하세요 (GRANT 추출용):"
for ACCOUNT in "'cotdl'@'%'" "'cotdl'@'localhost'" "'cotdl'@'127.0.0.1'" "'cotdlbk'@'%'"; do
    echo "" >> "${GRANT_FILE}"
    echo "-- ${ACCOUNT} 계정" >> "${GRANT_FILE}"
    mysql -u "${MARIADB_USER}" -p -N -B -e "SHOW GRANTS FOR ${ACCOUNT};" 2>/dev/null \
        | while read -r line; do echo "${line};" >> "${GRANT_FILE}"; done \
        || echo "-- [경고] ${ACCOUNT} 계정 GRANT 추출 실패 - 수동 확인 필요" >> "${GRANT_FILE}"
done

echo "" >> "${GRANT_FILE}"
echo "FLUSH PRIVILEGES;" >> "${GRANT_FILE}"

# 수동 템플릿
cat > "${PACK_DIR}/db/cotdl_users_template.sql" << 'EOF'
-- ==========================================================
-- cotdl 사용자 계정 수동 생성 템플릿
-- [비밀번호] 부분을 반드시 실제 비밀번호로 교체하세요!
-- ==========================================================

CREATE USER IF NOT EXISTS 'cotdl'@'%' IDENTIFIED BY '[비밀번호]';
CREATE USER IF NOT EXISTS 'cotdl'@'localhost' IDENTIFIED BY '[비밀번호]';
CREATE USER IF NOT EXISTS 'cotdl'@'127.0.0.1' IDENTIFIED BY '[비밀번호]';
CREATE USER IF NOT EXISTS 'cotdlbk'@'%' IDENTIFIED BY '[비밀번호]';

GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'%';
GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'localhost';
GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'127.0.0.1';

-- cotdlbk: SELECT만이면 아래, ALL이면 그 아래
GRANT SELECT ON cotdl.* TO 'cotdlbk'@'%';
-- GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdlbk'@'%';

FLUSH PRIVILEGES;
EOF

echo "   사용자 계정 파일 생성 완료"

#=============================================================================
# STEP 3. Tomcat 폴더 복사 (기존 구조 보존)
#=============================================================================
echo ""
echo "[STEP 3/6] Tomcat 폴더 복사..."

# symlink resolve해서 실제 Tomcat 디렉토리명 가져오기
if [ -L "${TOMCAT_LATEST}" ]; then
    TOMCAT_REAL=$(readlink -f "${TOMCAT_LATEST}")
    TOMCAT_DIRNAME=$(basename "${TOMCAT_REAL}")
    echo "   symlink 감지: ${TOMCAT_LATEST} -> ${TOMCAT_REAL}"
elif [ -d "${TOMCAT_LATEST}" ]; then
    TOMCAT_REAL="${TOMCAT_LATEST}"
    TOMCAT_DIRNAME=$(basename "${TOMCAT_REAL}")
else
    # /opt/tomcat 전체 복사 시도
    TOMCAT_REAL="/opt/tomcat"
    TOMCAT_DIRNAME=""
fi

if [ -d "${TOMCAT_REAL}" ]; then
    # /opt/tomcat 전체를 복사 (apache-tomcat-x.x.x + latest symlink 구조 보존)
    rsync -a --progress \
        --exclude='logs/*' \
        --exclude='temp/*' \
        --exclude='work/*' \
        /opt/tomcat/ "${PACK_DIR}/tomcat/"

    # 빈 런타임 디렉토리 유지
    if [ -n "${TOMCAT_DIRNAME}" ]; then
        mkdir -p "${PACK_DIR}/tomcat/${TOMCAT_DIRNAME}/"{logs,temp,work}
    fi

    echo "   Tomcat 복사 완료: $(du -sh "${PACK_DIR}/tomcat/" | cut -f1)"
    echo "   구조: /opt/tomcat/${TOMCAT_DIRNAME} + latest symlink"
else
    echo "   [경고] Tomcat 경로를 찾을 수 없습니다: ${TOMCAT_REAL}"
    echo "   수동으로 /opt/tomcat 폴더를 ${PACK_DIR}/tomcat/ 에 복사하세요."
fi

#=============================================================================
# STEP 4. Java Corretto 11 복사
#=============================================================================
echo ""
echo "[STEP 4/6] Amazon Corretto 11 JDK 복사..."

if [ -d "${JAVA_HOME_DIR}" ]; then
    rsync -a --progress "${JAVA_HOME_DIR}/" "${PACK_DIR}/java/amazon-corretto-11/"
    echo "   Java 복사 완료: $(du -sh "${PACK_DIR}/java/" | cut -f1)"
else
    echo "   [경고] Java 경로를 찾을 수 없습니다: ${JAVA_HOME_DIR}"
    echo "   수동으로 Java 폴더를 ${PACK_DIR}/java/amazon-corretto-11/ 에 복사하세요."
fi

#=============================================================================
# STEP 5. Tomcat 서비스 파일 백업
#=============================================================================
echo ""
echo "[STEP 5/6] systemd 서비스 파일 백업..."

if [ -f "/etc/systemd/system/tomcat.service" ]; then
    cp /etc/systemd/system/tomcat.service "${PACK_DIR}/scripts/tomcat.service.bak"
    echo "   현재 서버 tomcat.service 백업 완료 (참고용)"
fi

#=============================================================================
# STEP 6. 배포 스크립트 복사
#=============================================================================
echo ""
echo "[STEP 6/6] 배포 스크립트 복사..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cp "${SCRIPT_DIR}/02_deploy_mariadb.sh" "${PACK_DIR}/scripts/" 2>/dev/null || true
cp "${SCRIPT_DIR}/03_deploy_tomcat.sh" "${PACK_DIR}/scripts/" 2>/dev/null || true
cp "${SCRIPT_DIR}/04_dlm_service.sh" "${PACK_DIR}/scripts/" 2>/dev/null || true

#=============================================================================
# 최종 아카이브 생성
#=============================================================================
echo ""
echo "============================================="
echo " 패키징 완료! 아카이브 생성 중..."
echo "============================================="

cd /backup
tar czf "dlm_deploy_$(date +%Y%m%d).tar.gz" "$(basename "${PACK_DIR}")"

echo ""
echo "============================================="
echo " 패키징 결과"
echo "============================================="
echo ""
echo " 패키징 디렉토리: ${PACK_DIR}"
echo ""
echo " 디렉토리 구조:"
echo " ${PACK_DIR}/"
echo " ├── db/"
echo " │   ├── cotdl_dump.sql              - DB 전체 덤프"
echo " │   ├── cotdl_users.sql             - 사용자 계정/권한 (자동추출)"
echo " │   └── cotdl_users_template.sql    - 사용자 계정/권한 (수동 템플릿)"
echo " ├── tomcat/"
echo " │   ├── apache-tomcat-9.0.87/       - Tomcat 본체"
echo " │   └── latest -> apache-tomcat-... - symlink"
echo " ├── java/"
echo " │   └── amazon-corretto-11/         - Amazon Corretto JDK 11"
echo " └── scripts/"
echo "     ├── 02_deploy_mariadb.sh         - DB 배포 스크립트"
echo "     ├── 03_deploy_tomcat.sh         - Tomcat 배포 스크립트"
echo "     ├── 04_dlm_service.sh           - 서비스 관리 스크립트"
echo "     └── tomcat.service.bak          - 현재 서버 서비스 파일 (참고용)"
echo ""
echo " 아카이브: /backup/dlm_deploy_$(date +%Y%m%d).tar.gz"
echo " 크기: $(du -sh "${PACK_DIR}" | cut -f1)"
echo ""
echo " ※ 고객사 전달: /backup/dlm_deploy_$(date +%Y%m%d).tar.gz"
echo " ※ USB 등으로 전달 후 02_deploy_target_server.sh 실행"
echo "============================================="
