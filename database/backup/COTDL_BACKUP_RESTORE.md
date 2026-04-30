# DLM 데이터베이스 백업/복원 가이드 (MariaDB)

## 개요

| 항목 | 값 |
|---|---|
| 대상 DB | `cotdl` — DLM 메인 DB (테이블, 데이터, 설정 전체) |
| 호스트 | `localhost` |
| 포트 | `3306` |
| 사용자 | `root` |
| 비밀번호 | `!Dlm1234` |
| 컨테이너명 | `dlm-mariadb` (Docker Compose 환경) |
| 본 가이드 위치 | `/app/Datablocks/database/backup/COTDL_BACKUP_RESTORE.md` (백업 dump 파일과 동일 폴더 — `.gitignore` 예외로 git 추적됨) |

> ★ 비밀번호에 `!` 특수문자 포함 → 작은따옴표로 감싸거나 `MYSQL_PWD` 환경변수 사용 (아래 § "비밀번호 처리 방법" 참고)
>
> ★ Docker 환경에서는 [§ 4-2 (docker exec)](#4-2-docker-환경-압축-백업--본-repo-표준--dlm-mariadb-컨테이너) 권장

---

## 비밀번호 처리 방법 (`!` 특수문자)

```bash
# 방법 1: 작은따옴표로 감싸기 (권장)
mysqldump -u root -p'!Dlm1234' ...

# 방법 2: MYSQL_PWD 환경변수 (스크립트에서 권장)
export MYSQL_PWD='!Dlm1234'
mysqldump -u root ...
mysql -u root ...

# 방법 3: -p만 쓰면 프롬프트에서 입력 (대화형)
mysqldump -u root -p ...
```

> ★ 아래 모든 예시는 **방법 1 (작은따옴표)** 기준입니다. 쉘 스크립트에서는 **방법 2 (`MYSQL_PWD`)** 를 권장합니다.

---

## 1. 전체 백업 (★ 권장)

```bash
# 백업 디렉토리 생성
mkdir -p /home/dlm/backup

# cotdl 전체 백업
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --routines \
  --triggers \
  --default-character-set=utf8mb4 \
  cotdl > /home/dlm/backup/cotdl_$(date +%Y%m%d_%H%M%S).sql

# 결과 확인
ls -lh /home/dlm/backup/cotdl_*.sql
```

---

## 2. 특정 테이블만 백업

> ★ 형식: `mysqldump [옵션] DB명 테이블1 테이블2 ... > 파일명`

### 예 1: 작업 관련 테이블 (piiorder + orderstep + ordersteptable)

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --default-character-set=utf8mb4 \
  cotdl tbl_piiorder tbl_piiorderstep tbl_piiordersteptable \
  > /home/dlm/backup/cotdl_order_$(date +%Y%m%d_%H%M%S).sql
```

### 예 2: 사용자/권한 테이블

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --default-character-set=utf8mb4 \
  cotdl tbl_member tbl_authority \
  > /home/dlm/backup/cotdl_member_$(date +%Y%m%d_%H%M%S).sql
```

### 예 3: 접속기록 테이블

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --default-character-set=utf8mb4 \
  cotdl tbl_access_log tbl_access_log_source tbl_access_log_config \
        tbl_access_log_alert_rule tbl_access_log_alert \
  > /home/dlm/backup/cotdl_accesslog_$(date +%Y%m%d_%H%M%S).sql
```

### 예 4: 탐지 (Discovery) 테이블

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --default-character-set=utf8mb4 \
  cotdl tbl_discovery_pii_type tbl_discovery_rule \
        tbl_discovery_scan_job_v2 tbl_discovery_scan_execution \
        tbl_discovery_scan_result tbl_discovery_config \
  > /home/dlm/backup/cotdl_discovery_$(date +%Y%m%d_%H%M%S).sql
```

### 예 5: 메타/인벤토리 테이블

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --default-character-set=utf8mb4 \
  cotdl tbl_piitable tbl_metatable tbl_piidatabase tbl_lkpiiscrtype \
  > /home/dlm/backup/cotdl_meta_$(date +%Y%m%d_%H%M%S).sql
```

### 예 6: 고객 추출 데이터 (대용량 주의)

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --default-character-set=utf8mb4 \
  cotdl tbl_piiextract tbl_piirestore tbl_piicontract tbl_testdata \
  > /home/dlm/backup/cotdl_extract_$(date +%Y%m%d_%H%M%S).sql
```

---

## 3. 데이터 없이 구조 (DDL) 만 백업

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --no-data \
  --routines \
  --triggers \
  --default-character-set=utf8mb4 \
  cotdl > /home/dlm/backup/cotdl_ddl_$(date +%Y%m%d_%H%M%S).sql
```

---

## 4. gz 압축 백업/복원 (대용량 DB — 디스크 절약, ★ 권장)

### 압축 백업 (full-fidelity 옵션 적용)

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --hex-blob \
  --default-character-set=utf8mb4 \
  --add-drop-database --databases cotdl \
  | gzip > /home/dlm/backup/cotdl_backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### 압축 복원

> `--add-drop-database --databases` 옵션으로 dump 했으면 DB 자동 생성/덮어쓰기 됨.

```bash
gunzip < /home/dlm/backup/cotdl_backup_20260415_120000.sql.gz \
  | mysql -h localhost -P 3306 -u root -p'!Dlm1234' --default-character-set=utf8mb4
```

---

## 4-2. Docker 환경 압축 백업 (★ 본 repo 표준 — `dlm-mariadb` 컨테이너)

호스트에서 컨테이너 `mysqldump` 를 실행하고 호스트 파일로 출력 받기.
`!` 특수문자 처리는 `docker exec -e MYSQL_PWD='...'` 환경변수 전달.

### 백업

```bash
TS=$(date +%Y%m%d_%H%M%S)
OUT=/app/Datablocks/database/backup/cotdl_backup_${TS}.sql.gz

docker exec -e MYSQL_PWD='!Dlm1234' dlm-mariadb \
  mysqldump -u root \
    --single-transaction --routines --triggers --events \
    --hex-blob --default-character-set=utf8mb4 \
    --add-drop-database --databases cotdl \
  | gzip > "$OUT"
```

### 검증

```bash
gunzip -t "$OUT" && echo "✓ gzip OK"
ls -lh "$OUT"
gunzip -c "$OUT" | head -10                  # 서버 버전 / DB 헤더 확인
gunzip -c "$OUT" | grep -c '^CREATE TABLE'   # 테이블 수
gunzip -c "$OUT" | grep -c '^INSERT INTO'    # INSERT 문 수
```

### 복원 (Docker 환경)

```bash
gunzip -c /app/Datablocks/database/backup/cotdl_backup_<YYYYMMDD_HHMMSS>.sql.gz \
  | docker exec -i -e MYSQL_PWD='!Dlm1234' dlm-mariadb \
      mysql -u root --default-character-set=utf8mb4
```

---

## 5. 복원 — 사전 준비 (DB/사용자가 없는 경우)

```bash
# root로 접속
mysql -h localhost -P 3306 -u root -p'!Dlm1234'
```

mysql 프롬프트에서 아래 SQL 실행:

```sql
CREATE DATABASE IF NOT EXISTS cotdl DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER IF NOT EXISTS 'cotdl'@'%'         IDENTIFIED BY '!Dlm1234';
CREATE USER IF NOT EXISTS 'cotdl'@'localhost'  IDENTIFIED BY '!Dlm1234';
CREATE USER IF NOT EXISTS 'cotdl'@'127.0.0.1' IDENTIFIED BY '!Dlm1234';

GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'%';
GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'localhost';
GRANT ALL PRIVILEGES ON cotdl.* TO 'cotdl'@'127.0.0.1';
FLUSH PRIVILEGES;
EXIT;
```

---

## 6. 복원 실행

```bash
# 백업 파일에서 cotdl로 복원
mysql -h localhost -P 3306 -u root -p'!Dlm1234' \
  --default-character-set=utf8mb4 \
  cotdl < /home/dlm/backup/cotdl_20260415_120000.sql
```

---

## 7. 백업/복원 검증

### 백업 파일 목록 확인

```bash
ls -lh /home/dlm/backup/cotdl*.sql*
```

### 백업 파일 내용 미리보기 (첫 30 줄)

```bash
head -30 /home/dlm/backup/cotdl_20260415_120000.sql
```

### 압축 파일 미리보기

```bash
zcat /home/dlm/backup/cotdl_20260415_120000.sql.gz | head -30
```

### 테이블별 건수/용량 확인

```bash
mysql -h localhost -P 3306 -u root -p'!Dlm1234' -e "
SELECT table_name, table_rows,
       ROUND(data_length/1024/1024, 1) AS data_mb,
       ROUND(index_length/1024/1024, 1) AS index_mb
  FROM information_schema.tables
 WHERE table_schema = 'cotdl'
 ORDER BY table_rows DESC;
"
```

### DB 전체 크기 확인

```bash
mysql -h localhost -P 3306 -u root -p'!Dlm1234' -e "
SELECT table_schema AS db,
       COUNT(*) AS tables,
       ROUND(SUM(data_length + index_length)/1024/1024, 1) AS total_mb
  FROM information_schema.tables
 WHERE table_schema = 'cotdl'
 GROUP BY table_schema;
"
```

### 사용자/권한 확인

```bash
mysql -h localhost -P 3306 -u root -p'!Dlm1234' -e "
SELECT User, Host FROM mysql.user WHERE User = 'cotdl';
"
```

---

## 8. 자동 백업 스크립트 (cron 등록용)

`/home/dlm/backup/auto_backup.sh` 로 저장:

```bash
cat > /home/dlm/backup/auto_backup.sh << 'SCRIPT'
#!/bin/bash
# DLM DB 자동 백업 스크립트
# cron 예: 0 2 * * * /home/dlm/backup/auto_backup.sh

BACKUP_DIR="/home/dlm/backup"
KEEP_DAYS=30
export MYSQL_PWD='!Dlm1234'

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "[$(date)] 백업 시작"

# cotdl 전체 압축 백업
mysqldump -h localhost -P 3306 -u root \
  --single-transaction \
  --routines \
  --triggers \
  --default-character-set=utf8mb4 \
  cotdl | gzip > "${BACKUP_DIR}/cotdl_auto_${TIMESTAMP}.sql.gz"

if [ $? -eq 0 ]; then
    SIZE=$(ls -lh "${BACKUP_DIR}/cotdl_auto_${TIMESTAMP}.sql.gz" | awk '{print $5}')
    echo "[$(date)] 백업 완료: cotdl_auto_${TIMESTAMP}.sql.gz (${SIZE})"
else
    echo "[$(date)] 백업 실패!"
    exit 1
fi

# 30일 이상 된 백업 삭제
DELETED=$(find "${BACKUP_DIR}" -name "cotdl_auto_*.sql.gz" -mtime +${KEEP_DAYS} -delete -print | wc -l)
echo "[$(date)] 오래된 백업 ${DELETED}개 삭제 (${KEEP_DAYS}일 초과)"
SCRIPT

chmod +x /home/dlm/backup/auto_backup.sh
```

cron 등록 (매일 새벽 2시) — `crontab -e` 에서 아래 추가:

```cron
0 2 * * * /home/dlm/backup/auto_backup.sh >> /home/dlm/backup/backup.log 2>&1
```

---

## 9. DDL 패치 전 안전 백업 (★ 패치 작업 시 필수)

> DDL 패치 적용 **전에 반드시 실행!** 패치 실패 시 이 백업으로 복원 가능.

### 호스트 mariadb 클라이언트

```bash
mysqldump -h localhost -P 3306 -u root -p'!Dlm1234' \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --hex-blob \
  --default-character-set=utf8mb4 \
  --add-drop-database --databases cotdl \
  | gzip > /home/dlm/backup/cotdl_pre_patch_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Docker 환경

```bash
TS=$(date +%Y%m%d_%H%M%S)
docker exec -e MYSQL_PWD='!Dlm1234' dlm-mariadb \
  mysqldump -u root \
    --single-transaction --routines --triggers --events \
    --hex-blob --default-character-set=utf8mb4 \
    --add-drop-database --databases cotdl \
  | gzip > /app/Datablocks/database/backup/cotdl_pre_patch_${TS}.sql.gz
```

### 백업 확인

```bash
ls -lh /app/Datablocks/database/backup/cotdl_pre_patch_*.sql.gz
```

### 패치 적용 (예: 2026-04-14 패치)

```bash
mysql -h localhost -P 3306 -u cotdl -p'!Dlm1234' cotdl < 30_DDL_MASTER_ACCESSLOG.sql
mysql -h localhost -P 3306 -u cotdl -p'!Dlm1234' cotdl < 20_DDL_MASTER_DISCOVERY.sql
mysql -h localhost -P 3306 -u cotdl -p'!Dlm1234' cotdl < patches/IMCAPITAL_PATCH_20260414.sql
mysql -h localhost -P 3306 -u cotdl -p'!Dlm1234' cotdl < patches/IMCAPITAL_INDEX_PATCH_20260414.sql
```

### 패치 실패 시 복원

```bash
gunzip < /home/dlm/backup/cotdl_pre_patch_20260415_120000.sql.gz \
  | mysql -h localhost -P 3306 -u root -p'!Dlm1234' --default-character-set=utf8mb4 cotdl
```

---

## mysqldump 주요 옵션 설명

| 옵션 | 설명 |
|---|---|
| `--single-transaction` | InnoDB 테이블을 락 없이 일관된 스냅샷 백업 |
| `--routines` | 스토어드 프로시저/함수 포함 |
| `--triggers` | 트리거 포함 |
| `--events` | 이벤트 스케줄러 (event scheduler) 정의 포함 |
| `--hex-blob` | BLOB/BINARY 컬럼을 16진수로 dump → 문자셋·라인엔딩 이슈 없이 바이너리 안전 복원 |
| `--add-drop-database` | 복원 시 기존 DB 를 자동 DROP 후 재생성 (덮어쓰기) |
| `--databases <DB>` | `USE` / `CREATE DATABASE` 문 dump 에 포함 → 복원 시 `mysql` 명령에서 별도로 DB 지정 안 해도 됨 |
| `--no-data` | 구조 (DDL) 만 백업, 데이터 제외 |
| `--default-character-set=utf8mb4` | 한글/이모지 깨짐 방지 |
| `-p'비밀번호'` | 비밀번호 직접 지정 (특수문자는 작은따옴표) |
| `-e MYSQL_PWD='...'` | `docker exec` 시 환경변수로 비밀번호 안전 전달 (`!` 특수문자 history expansion 회피) |
