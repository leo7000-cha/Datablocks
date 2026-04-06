#!/bin/bash
# ==============================================================================
# STEP 2: cotdl 사용자 계정 복구
# - cotdl_users.sql 에 PASSWORD 해시가 포함되어 있음
# - Docker 환경에서는 '%' 호스트만으로 충분하지만 호환성을 위해 전부 생성
# ==============================================================================

echo "[init] Creating cotdl users..."

mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" < /docker-entrypoint-initdb.d/cotdl_users.sql.data

echo "[init] Users created. Verifying..."
mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "SELECT User, Host FROM mysql.user WHERE User IN ('cotdl', 'cotdlbk');"
