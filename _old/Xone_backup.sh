#!/bin/bash
#=============================================================================
# DLM DB 백업 스크립트
#
# 기존 /datablocks 전용 → 스크립트 위치 기준으로도 실행 가능하도록 개선
#
# 사용법:
#   sudo bash Xone_backup.sh                          ← 자동 (스크립트위치/backup)
#   sudo bash Xone_backup.sh /path/to/backup_dir      ← 백업 디렉토리 지정
#
# DB 접속 방식 (우선순위):
#   1) 스크립트와 같은 디렉토리의 .my.cnf
#   2) /datablocks/.my.cnf (기존 경로)
#   3) ~/.my.cnf (MariaDB 기본)
#   4) 위 모두 없으면 -p 옵션으로 비밀번호 직접 입력
#
# crontab 등록 예시:
#   0 2 * * * /opt/tomcat/Xone_backup.sh >> /var/log/dlm_backup.log 2>&1
#=============================================================================

set -euo pipefail

# ── 스크립트 위치 감지 ───────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 설정 ────────────────────────────────────────────────────
DB_USER="root"
DB_NAME="cotdl"
RETENTION_DAYS=3

# ── 백업 디렉토리 결정 ──────────────────────────────────────
if [ -n "${1:-}" ]; then
    BACKUP_DIR="${1}"
elif [ -d "/datablocks/backup" ] || [ -d "/datablocks" ]; then
    BACKUP_DIR="/datablocks/backup"
else
    BACKUP_DIR="${SCRIPT_DIR}/backup"
fi

# ── DB 접속 설정 파일 탐색 ──────────────────────────────────
MYCNF=""
MYSQL_OPTS=""

if [ -f "${SCRIPT_DIR}/.my.cnf" ]; then
    MYCNF="${SCRIPT_DIR}/.my.cnf"
elif [ -f "/datablocks/.my.cnf" ]; then
    MYCNF="/datablocks/.my.cnf"
elif [ -f "${HOME}/.my.cnf" ]; then
    MYCNF="${HOME}/.my.cnf"
fi

if [ -n "${MYCNF}" ]; then
    MYSQL_OPTS="--defaults-extra-file=${MYCNF}"
else
    # .my.cnf 없으면 -p 옵션으로 비밀번호 직접 입력
    MYSQL_OPTS="-u ${DB_USER} -p"
fi

# ── 날짜/파일명 ─────────────────────────────────────────────
TODAY=$(date +"%Y%m%d")
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TODAY}.sql"
COMPRESSED_FILE="${BACKUP_FILE}.gz"

# ── 로그 함수 ───────────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "============================================="
log " DLM DB 백업 시작"
log " DB:        ${DB_NAME}"
log " 백업경로:  ${BACKUP_DIR}"
log " 인증방식:  ${MYCNF:-비밀번호 직접 입력}"
log " 보존기간:  ${RETENTION_DAYS}일"
log "============================================="

# ── 백업 디렉토리 생성 ──────────────────────────────────────
if [ ! -d "${BACKUP_DIR}" ]; then
    log "백업 디렉토리 생성: ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"
fi

# ── 기존 백업 파일 확인 ─────────────────────────────────────
if [ -f "${COMPRESSED_FILE}" ]; then
    log "[WARN] 오늘자 백업 파일이 이미 존재합니다: ${COMPRESSED_FILE}"
    log "  덮어쓰기 진행..."
    rm -f "${COMPRESSED_FILE}"
fi
rm -f "${BACKUP_FILE}"

# ── mysqldump 수행 ──────────────────────────────────────────
log "mysqldump 시작..."

if [ -n "${MYCNF}" ]; then
    mysqldump ${MYSQL_OPTS} \
        --single-transaction \
        --quick \
        --routines \
        --triggers \
        --default-character-set=utf8mb4 \
        "${DB_NAME}" > "${BACKUP_FILE}"
else
    log "  MariaDB root 비밀번호를 입력하세요:"
    mysqldump ${MYSQL_OPTS} \
        --single-transaction \
        --quick \
        --routines \
        --triggers \
        --default-character-set=utf8mb4 \
        "${DB_NAME}" > "${BACKUP_FILE}"
fi

DUMP_SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
log "mysqldump 완료: ${BACKUP_FILE} (${DUMP_SIZE})"

# ── 백업 파일 압축 ──────────────────────────────────────────
log "gzip 압축 시작..."
gzip "${BACKUP_FILE}"
GZ_SIZE=$(du -h "${COMPRESSED_FILE}" | cut -f1)
log "압축 완료: ${COMPRESSED_FILE} (${GZ_SIZE})"

# ── 오래된 백업 삭제 ────────────────────────────────────────
log "${RETENTION_DAYS}일 초과 백업 파일 삭제..."
DELETED=$(find "${BACKUP_DIR}" -type f -name "db_backup_*.gz" -mtime +${RETENTION_DAYS} -print)
if [ -n "${DELETED}" ]; then
    echo "${DELETED}" | while read -r f; do
        log "  삭제: $(basename "$f")"
        rm -f "$f"
    done
else
    log "  삭제 대상 없음"
fi

# ── 현재 백업 목록 ──────────────────────────────────────────
log ""
log "현재 백업 파일 목록:"
ls -lh "${BACKUP_DIR}"/db_backup_*.gz 2>/dev/null | while read -r line; do
    log "  ${line}"
done

log ""
log "============================================="
log " DB 백업 완료"
log "============================================="
