#!/bin/bash
# ==============================================================================
# STEP 1: cotdl 데이터베이스 복구 (배포 스크립트 02-1 기준)
# - varchar(1024) → text 변환
# - ROW_FORMAT=DYNAMIC 추가
# ==============================================================================

echo "[init] Restoring cotdl database from dump..."

sed -e 's/`question` varchar(1024)/`question` text/g' \
    -e 's/ENGINE=InnoDB/ENGINE=InnoDB ROW_FORMAT=DYNAMIC/g' \
    /docker-entrypoint-initdb.d/cotdl_dump.sql.data | mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -f

echo "[init] cotdl database restored."
