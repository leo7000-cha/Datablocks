#!/bin/bash
# ==============================================================================
# DLM 스키마 비교 도구 (자동 실행)
# 고객 DB(COTDL) vs 기준 DDL → 패치 SQL 자동 생성
# ==============================================================================
#
# ■ 사용법 (Docker 환경 — 3단계 복붙)
#
#   1) DDL 파일을 컨테이너로 복사
#      docker cp DLM/deploy/ddl dlm-mariadb:/tmp/ddl
#
#   2) 컨테이너 안에서 실행 (결과를 파일로 저장)
#      docker exec dlm-mariadb sh -c \
#        "MYSQL_USER=root MYSQL_PWD='\!Dlm1234' bash /tmp/ddl/SCHEMA_DIFF_RUN.sh -o /tmp/patch_result.sql"
#
#   3) 결과 파일을 호스트로 꺼내서 확인
#      docker cp dlm-mariadb:/tmp/patch_result.sql ./patch_result.sql
#      cat ./patch_result.sql
#
# ==============================================================================

set -e

OUTPUT_FILE=""
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output) OUTPUT_FILE="$2"; shift 2 ;;
        *)           shift ;;
    esac
done

# --- 인증 정보 (환경변수 MYSQL_USER / MYSQL_PWD 또는 대화형 입력) ---
if [ -z "$MYSQL_USER" ]; then
    read -rp "DB User [root]: " MYSQL_USER
    MYSQL_USER="${MYSQL_USER:-root}"
fi
if [ -z "$MYSQL_PWD" ]; then
    read -rsp "DB Password: " MYSQL_PWD
    echo ""
fi
export MYSQL_PWD

MYSQL_OPTS="-u $MYSQL_USER"
[ -n "$MYSQL_HOST" ] && MYSQL_OPTS="$MYSQL_OPTS -h $MYSQL_HOST"
[ -n "$MYSQL_PORT" ] && MYSQL_OPTS="$MYSQL_OPTS -P $MYSQL_PORT"

MYSQL="mysql $MYSQL_OPTS"

# 종료 시 정리
cleanup() {
    $MYSQL -e "DROP DATABASE IF EXISTS COTDL_REF;" 2>/dev/null || true
}
trap cleanup EXIT

# --- 연결 테스트 ---
if ! $MYSQL -e "SELECT 1" >/dev/null 2>&1; then
    echo "[ERROR] DB 연결 실패. 계정 정보를 확인하세요."
    exit 1
fi

# DDL 파일 경로
DDL_FILE="$SCRIPT_DIR/XONE_TABLE_DDL_MYSQL.sql"
DIFF_SQL="$SCRIPT_DIR/SCHEMA_DIFF.sql"
[ ! -f "$DDL_FILE" ] && DDL_FILE="/tmp/ddl/XONE_TABLE_DDL_MYSQL.sql"
[ ! -f "$DIFF_SQL" ] && DIFF_SQL="/tmp/ddl/SCHEMA_DIFF.sql"
[ ! -f "$DDL_FILE" ] && DDL_FILE="/tmp/XONE_TABLE_DDL_MYSQL.sql"
[ ! -f "$DIFF_SQL" ] && DIFF_SQL="/tmp/SCHEMA_DIFF.sql"

if [ ! -f "$DDL_FILE" ]; then echo "[ERROR] XONE_TABLE_DDL_MYSQL.sql 을 찾을 수 없습니다."; exit 1; fi
if [ ! -f "$DIFF_SQL" ]; then echo "[ERROR] SCHEMA_DIFF.sql 을 찾을 수 없습니다."; exit 1; fi

echo "=============================================="
echo " DLM Schema Diff Tool"
echo "=============================================="
echo ""

# --- STEP 1 ---
echo "[STEP 1/4] 임시 기준 DB(COTDL_REF) 생성..."
$MYSQL -e "DROP DATABASE IF EXISTS COTDL_REF; CREATE DATABASE COTDL_REF;"

# --- STEP 2 ---
echo "[STEP 2/4] 기준 DDL을 COTDL_REF에 로드..."
sed 's/`COTDL`/`COTDL_REF`/g; s/COTDL\./COTDL_REF./g' "$DDL_FILE" | $MYSQL COTDL_REF

REF_COUNT=$($MYSQL -N -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='COTDL_REF';")
CUR_COUNT=$($MYSQL -N -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='COTDL';")
echo "  기준 DDL 테이블: ${REF_COUNT}개"
echo "  고객 DB 테이블:  ${CUR_COUNT}개"
echo ""

# --- STEP 3 ---
echo "[STEP 3/4] 스키마 비교 중..."
echo ""

HEADER="-- ==============================================================================
-- DLM 스키마 패치 스크립트 (자동 생성)
-- 생성일: $(date '+%Y-%m-%d %H:%M:%S')
-- 기준 DDL 테이블: ${REF_COUNT}개 / 고객 DB 테이블: ${CUR_COUNT}개
-- ==============================================================================
-- ★ [신규 테이블]  : DDL에서 CREATE TABLE 찾아서 실행
-- ★ ALTER TABLE    : 누락 컬럼 추가 또는 타입 변경 (바로 실행 가능)
-- ※ [참고]         : 고객 커스텀 또는 폐기 대상 (자동 처리 안 함)
-- =============================================================================="

if [ -n "$OUTPUT_FILE" ]; then
    echo "$HEADER" > "$OUTPUT_FILE"
    $MYSQL -N < "$DIFF_SQL" >> "$OUTPUT_FILE"

    PATCH_CNT=$(grep -c "^ALTER\|^\-\- ★" "$OUTPUT_FILE" 2>/dev/null || echo "0")
    INFO_CNT=$(grep -c "^-- ※" "$OUTPUT_FILE" 2>/dev/null || echo "0")

    echo "  패치 필요 항목: ${PATCH_CNT}건"
    echo "  참고 항목:      ${INFO_CNT}건"
    echo ""
    echo "  결과 파일: $OUTPUT_FILE"
else
    echo "$HEADER"
    echo ""
    $MYSQL -N < "$DIFF_SQL"
fi

# --- STEP 4: 정리 (trap EXIT에서 처리) ---
echo ""
echo "[STEP 4/4] 임시 기준 DB(COTDL_REF) 삭제..."

echo ""
echo "[완료] 위 결과를 검토 후 필요한 SQL만 실행하세요."
echo "=============================================="
