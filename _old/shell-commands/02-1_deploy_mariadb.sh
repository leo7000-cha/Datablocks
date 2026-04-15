#!/bin/bash
#=============================================================================
# DLM MariaDB 배포 스크립트 (고객사 서버 - Ubuntu)
# 한국손해사정 초기 배포용
#
# 02_deploy_target_server.sh 에서 분리된 DB 전용 스크립트
# Tomcat/Java 설치 후 별도로 실행
#
# 실행: sudo bash 04_deploy_mariadb.sh /path/to/dlm_deploy_YYYYMMDD.tar.gz
#   또는 이미 해제된 경우:
#       sudo bash 04_deploy_mariadb.sh /path/to/dlm_deploy_YYYYMMDD (디렉토리)
#=============================================================================

set -euo pipefail

MARIADB_ROOT_USER="root"

# ── MariaDB root 비밀번호 입력 (1회) ─────────────────────────────
echo ""
read -s -p "MariaDB root 비밀번호: " MARIADB_ROOT_PW
echo ""
export MYSQL_PWD="${MARIADB_ROOT_PW}"

# 접속 테스트
if ! mysql -u "${MARIADB_ROOT_USER}" -e "SELECT 1;" > /dev/null 2>&1; then
    echo "[오류] MariaDB 접속 실패 - 비밀번호를 확인하세요."
    unset MYSQL_PWD
    exit 1
fi
echo "   MariaDB 접속 확인 완료"

# ── 인자 확인 ─────────────────────────────────────────────────────
INPUT_PATH="${1:-}"

if [ -z "${INPUT_PATH}" ]; then
    echo "사용법: sudo bash $0 <패키징 아카이브 또는 해제된 디렉토리>"
    echo ""
    echo "예시:"
    echo "  sudo bash $0 /tmp/dlm_deploy_20260319.tar.gz"
    echo "  sudo bash $0 /tmp/dlm_deploy_20260319"
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "[오류] root 권한으로 실행하세요: sudo bash $0 ${INPUT_PATH}"
    exit 1
fi

echo "============================================="
echo " DLM MariaDB 배포 시작"
echo " 날짜: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================="

# ── 입력 경로 처리 (tar.gz 또는 디렉토리) ────────────────────────
if [ -f "${INPUT_PATH}" ]; then
    # tar.gz 파일인 경우 해제
    echo ""
    echo "[준비] 아카이브 해제..."
    WORK_DIR="/tmp/dlm_deploy_db_work"
    rm -rf "${WORK_DIR}"
    mkdir -p "${WORK_DIR}"
    tar xzf "${INPUT_PATH}" -C "${WORK_DIR}"

    PACK_DIR=$(find "${WORK_DIR}" -maxdepth 1 -type d -name "dlm_deploy_*" | head -1)
    if [ -z "${PACK_DIR}" ]; then
        PACK_DIR="${WORK_DIR}"
    fi
    echo "   해제 완료: ${PACK_DIR}"
elif [ -d "${INPUT_PATH}" ]; then
    # 이미 해제된 디렉토리
    PACK_DIR="${INPUT_PATH}"
    echo "   디렉토리 사용: ${PACK_DIR}"
else
    echo "[오류] 파일/디렉토리를 찾을 수 없습니다: ${INPUT_PATH}"
    exit 1
fi

# DB 파일 존재 확인
if [ ! -f "${PACK_DIR}/db/cotdl_dump.sql" ]; then
    echo "[오류] DB 덤프 파일 없음: ${PACK_DIR}/db/cotdl_dump.sql"
    echo "       ${PACK_DIR}/db/ 내용:"
    ls -la "${PACK_DIR}/db/" 2>/dev/null || echo "       db 디렉토리 없음"
    exit 1
fi

echo ""
echo "   덤프 파일: ${PACK_DIR}/db/cotdl_dump.sql ($(du -h "${PACK_DIR}/db/cotdl_dump.sql" | cut -f1))"
echo "   계정 파일: $(ls "${PACK_DIR}/db/cotdl_users"*.sql 2>/dev/null | tr '\n' ' ' || echo '없음')"

#=============================================================================
# STEP 1. MariaDB 글로벌 설정
#=============================================================================
echo ""
echo "[STEP 1/4] MariaDB 글로벌 설정 적용..."

mysql -u "${MARIADB_ROOT_USER}" -e "
SET GLOBAL innodb_file_format = 'Barracuda';
SET GLOBAL innodb_large_prefix = ON;
SET GLOBAL innodb_default_row_format = 'DYNAMIC';
SET GLOBAL innodb_strict_mode = OFF;
SET GLOBAL character_set_server = 'utf8mb4';
SET GLOBAL collation_server = 'utf8mb4_general_ci';
"
echo "   글로벌 설정 완료"

# my.cnf 영구 설정
MYCNF_DLM="/etc/mysql/mariadb.conf.d/99-dlm.cnf"
if [ -d "/etc/mysql/mariadb.conf.d" ]; then
    cat > "${MYCNF_DLM}" << 'EOF'
# DLM 전용 MariaDB 설정
[mysqld]
innodb_file_format = Barracuda
innodb_large_prefix = ON
innodb_default_row_format = DYNAMIC
innodb_strict_mode = OFF
character-set-server = utf8mb4
collation-server = utf8mb4_general_ci

[client]
default-character-set = utf8mb4
EOF
    echo "   영구 설정 파일: ${MYCNF_DLM}"
else
    echo "   [경고] /etc/mysql/mariadb.conf.d 없음 - 영구 설정 수동 필요"
fi

#=============================================================================
# STEP 2. cotdl 데이터베이스 복구
#=============================================================================
echo ""
echo "[STEP 2/4] cotdl 데이터베이스 복구..."
echo "   varchar(1024) → text 변환 + ROW_FORMAT=DYNAMIC 적용 중..."

sed -e 's/`question` varchar(1024)/`question` text/g' \
    -e 's/ENGINE=InnoDB/ENGINE=InnoDB ROW_FORMAT=DYNAMIC/g' \
    "${PACK_DIR}/db/cotdl_dump.sql" | mysql -u "${MARIADB_ROOT_USER}" -f

echo "   DB 복구 완료"

#=============================================================================
# STEP 3. 사용자 계정 + 권한 복구
#=============================================================================
echo ""
echo "[STEP 3/4] cotdl 사용자 계정 복구..."

if [ -f "${PACK_DIR}/db/cotdl_users.sql" ]; then
    echo "   cotdl_users.sql 적용..."
    mysql -u "${MARIADB_ROOT_USER}" < "${PACK_DIR}/db/cotdl_users.sql"
    echo "   사용자 계정 복구 완료"
elif [ -f "${PACK_DIR}/db/cotdl_users_template.sql" ]; then
    echo "   [경고] 자동 추출 파일 없음."
    echo "   템플릿을 수정 후 수동 실행하세요:"
    echo ""
    echo "   vi ${PACK_DIR}/db/cotdl_users_template.sql   ← 비밀번호 입력"
    echo "   mysql -u root -p < ${PACK_DIR}/db/cotdl_users_template.sql"
else
    echo "   [경고] 사용자 계정 파일 없음 - 수동 생성 필요"
fi

#=============================================================================
# STEP 4. 검증
#=============================================================================
echo ""
echo "[STEP 4/4] 검증..."

echo ""
echo "── DB 확인 ──"
mysql -u "${MARIADB_ROOT_USER}" -e "
USE cotdl;
SELECT '테이블 수' AS item, COUNT(*) AS value FROM information_schema.tables WHERE table_schema='cotdl'
UNION ALL
SELECT 'cotdl 계정 수', COUNT(*) FROM mysql.user WHERE User IN ('cotdl','cotdlbk');
" 2>/dev/null || echo "   [경고] DB 검증 실패 - 수동 확인 필요"

echo ""
echo "── 계정 확인 ──"
mysql -u "${MARIADB_ROOT_USER}" -e "
SELECT User, Host FROM mysql.user WHERE User IN ('cotdl', 'cotdlbk');
" 2>/dev/null || echo "   [경고] 계정 검증 실패"

echo ""
echo "── 권한 확인 ──"
for ACCOUNT in "'cotdl'@'%'" "'cotdl'@'localhost'" "'cotdl'@'127.0.0.1'" "'cotdlbk'@'%'"; do
    echo "   ${ACCOUNT}:"
    mysql -u "${MARIADB_ROOT_USER}" -N -e "SHOW GRANTS FOR ${ACCOUNT};" 2>/dev/null \
        | sed 's/^/     /' \
        || echo "     계정 없음"
done

unset MYSQL_PWD

echo ""
echo "============================================="
echo " MariaDB 배포 완료"
echo "============================================="
echo ""
echo " DB:     cotdl"
echo " 계정:   cotdl@%, cotdl@localhost, cotdl@127.0.0.1, cotdlbk@%"
echo " 설정:   ${MYCNF_DLM:-수동 설정 필요}"
echo ""
echo " ※ 문제 발생시 다시 실행 가능합니다 (덮어쓰기)"
echo " ※ Tomcat 시작 전에 DB 연결 테스트:"
echo "   mysql -u cotdl -p cotdl -e 'SHOW TABLES;'"
echo "============================================="
