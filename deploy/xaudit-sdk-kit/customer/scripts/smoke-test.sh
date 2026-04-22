#!/usr/bin/env bash
# ============================================================
# X-Audit 수신 엔드포인트 동작 확인 스모크 테스트
# 고객사 PoC 환경에서 실제 이벤트 한 건을 보내보고 DB에 저장되는지 검증.
#
# 사용법:
#   ./smoke-test.sh https://dlm.internal:8443
# ============================================================
set -u
URL="${1:-http://localhost:8080}/api/xaudit/events"
NOW=$(date '+%Y-%m-%d %H:%M:%S.000')
PK=$(date '+%Y%m%d')
REQ=$(cat /proc/sys/kernel/random/uuid 2>/dev/null | tr -d - || echo "smoke-$(date +%s)")

PAYLOAD=$(cat <<EOF
[
  {
    "type":"ACCESS","reqId":"$REQ","serviceName":"SMOKE_TEST",
    "userId":"smoke_tester","clientIp":"127.0.0.1","menuId":"SMOKE",
    "uri":"/smoke","httpMethod":"GET",
    "accessTime":"$NOW","partitionKey":"$PK",
    "httpStatus":200,"totalDurationMs":10,"resultCode":"SUCCESS"
  },
  {
    "type":"SQL","reqId":"$REQ","serviceName":"SMOKE_TEST",
    "userId":"smoke_tester","accessTime":"$NOW","partitionKey":"$PK",
    "sqlId":"smoke.test","sqlType":"SELECT",
    "sqlText":"SELECT 1",
    "durationMs":2,"affectedRows":1
  }
]
EOF
)

echo "→ POST  $URL"
echo "→ reqId $REQ"

echo "$PAYLOAD" | gzip | curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Content-Encoding: gzip" \
  --data-binary @- \
  "$URL"
echo
echo
echo "DB에서 확인:"
echo "  SELECT * FROM COTDL.TBL_XAUDIT_ACCESS_LOG WHERE req_id='$REQ';"
echo "  SELECT * FROM COTDL.TBL_XAUDIT_SQL_LOG    WHERE req_id='$REQ';"
