#!/bin/bash
# ==============================================================================
# Load timezone info into MariaDB (Asia/Seoul named TZ 사용을 위해 필수)
# docker-entrypoint-initdb.d 에서 자동 실행됨
# ==============================================================================

mysql_tzinfo_to_sql /usr/share/zoneinfo | mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" mysql 2>/dev/null
echo "[init] Timezone info loaded into MariaDB"
