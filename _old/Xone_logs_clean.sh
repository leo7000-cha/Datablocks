#!/bin/bash
#=============================================================================
# DLM 로그 정리 스크립트
#
# 지정된 디렉토리에서 N일 초과된 로그 파일을 삭제합니다.
#
# 사용법:
#   sudo bash Xone_logs_clean.sh          ← 기본 7일 초과 삭제
#   sudo bash Xone_logs_clean.sh 14       ← 14일 초과 삭제
#
# crontab 등록 예시:
#   0 3 * * * /opt/tomcat/Xone_logs_clean.sh >> /var/log/dlm_logclean.log 2>&1
#=============================================================================

RETENTION_DAYS="${1:-7}"

# ── 정리 대상 디렉토리 ──────────────────────────────────────
LOG_DIRS=(
    "/opt/tomcat/latest/logs/"
    "/opt/tomcat/latestapi/logs/"
    "/dlmapilogs/"
    "/dlmlogs/"
)

echo "============================================="
echo " DLM 로그 정리"
echo " 날짜: $(date '+%Y-%m-%d %H:%M:%S')"
echo " 보존: ${RETENTION_DAYS}일"
echo "============================================="

TOTAL_DELETED=0

for log_dir in "${LOG_DIRS[@]}"; do
    if [ -d "$log_dir" ]; then
        # 삭제 대상 파일 수 먼저 확인
        COUNT=$(find "$log_dir" -type f -mtime +${RETENTION_DAYS} 2>/dev/null | wc -l)
        if [ "$COUNT" -gt 0 ]; then
            echo ""
            echo "[${log_dir}] ${COUNT}개 파일 삭제"
            find "$log_dir" -type f -mtime +${RETENTION_DAYS} -print -exec rm -f {} \;
            TOTAL_DELETED=$((TOTAL_DELETED + COUNT))
        else
            echo "[${log_dir}] 삭제 대상 없음"
        fi
    else
        echo "[${log_dir}] 디렉토리 없음 - 건너뜀"
    fi
done

echo ""
echo "============================================="
echo " 정리 완료: 총 ${TOTAL_DELETED}개 파일 삭제"
echo "============================================="
