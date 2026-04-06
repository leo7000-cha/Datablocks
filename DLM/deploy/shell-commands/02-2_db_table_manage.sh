#!/bin/bash
#=============================================================================
# cotdl DB에서 TBL_SSM* 테이블 일괄 DROP
#
# 실행: sudo bash drop_tbl_ssm.sh
#=============================================================================

set -euo pipefail

MARIADB_ROOT_USER="root"
DB_NAME="cotdl"

# ── MariaDB root 비밀번호 입력 (1회) ─────────────────────────────
read -s -p "MariaDB root 비밀번호: " MARIADB_ROOT_PW
echo ""
export MYSQL_PWD="${MARIADB_ROOT_PW}"

if ! mysql -u "${MARIADB_ROOT_USER}" -e "SELECT 1;" > /dev/null 2>&1; then
    echo "[오류] MariaDB 접속 실패 - 비밀번호를 확인하세요."
    unset MYSQL_PWD
    exit 1
fi

# ── TBL_SSM* 테이블 목록 조회 ────────────────────────────────────
TABLES=$(mysql -u "${MARIADB_ROOT_USER}" -N -e \
    "SELECT table_name FROM information_schema.tables WHERE table_schema='${DB_NAME}' AND table_name LIKE 'TBL_SSM%' ORDER BY table_name;")

if [ -z "${TABLES}" ]; then
    echo "TBL_SSM* 테이블이 없습니다."
    unset MYSQL_PWD
    exit 0
fi

# ── 대상 테이블 표시 + 확인 ──────────────────────────────────────
COUNT=$(echo "${TABLES}" | wc -l)
echo ""
echo "=== DROP 대상 테이블 (${COUNT}개) ==="
echo "${TABLES}" | sed 's/^/  - /'
echo ""
read -p "정말 삭제하시겠습니까? (y/N): " CONFIRM

if [ "${CONFIRM}" != "y" ] && [ "${CONFIRM}" != "Y" ]; then
    echo "취소되었습니다."
    unset MYSQL_PWD
    exit 0
fi

# ── DROP 실행 ────────────────────────────────────────────────────
echo ""
for TBL in ${TABLES}; do
    mysql -u "${MARIADB_ROOT_USER}" "${DB_NAME}" -e "DROP TABLE \`${TBL}\`;"
    echo "  DROP: ${TBL}"
done

echo ""
echo "완료: ${COUNT}개 테이블 삭제됨"

unset MYSQL_PWD
