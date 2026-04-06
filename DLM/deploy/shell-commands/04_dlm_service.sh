#!/bin/bash
#=============================================================================
# DLM Tomcat 간편 관리 스크립트
# 사용법: sudo bash 03_dlm_service.sh {start|stop|restart|status|log|check}
#=============================================================================

TOMCAT_HOME="/opt/tomcat/latest"
SERVICE_NAME="tomcat"

case "${1:-}" in
    start)
        echo "Tomcat 시작..."
        sudo systemctl start ${SERVICE_NAME}
        sleep 3
        sudo systemctl status ${SERVICE_NAME} --no-pager
        ;;
    stop)
        echo "Tomcat 중지..."
        sudo systemctl stop ${SERVICE_NAME}
        echo "중지 완료"
        ;;
    restart)
        echo "Tomcat 재시작..."
        sudo systemctl restart ${SERVICE_NAME}
        sleep 3
        sudo systemctl status ${SERVICE_NAME} --no-pager
        ;;
    status)
        sudo systemctl status ${SERVICE_NAME} --no-pager
        echo ""
        echo "── 포트 확인 ──"
        ss -tlnp | grep 8080 || echo "8080 포트 미사용 (Tomcat 미기동)"
        echo ""
        echo "── PID 확인 ──"
        if [ -f "${TOMCAT_HOME}/temp/tomcat.pid" ]; then
            PID=$(cat "${TOMCAT_HOME}/temp/tomcat.pid")
            echo "PID: ${PID}"
            ps -p "${PID}" -o pid,user,%cpu,%mem,start,cmd --no-headers 2>/dev/null || echo "PID ${PID} 프로세스 없음"
        else
            echo "PID 파일 없음"
        fi
        echo ""
        echo "── 최근 로그 (10줄) ──"
        tail -10 "${TOMCAT_HOME}/logs/catalina.out" 2>/dev/null || echo "로그 파일 없음"
        ;;
    log)
        echo "catalina.out 실시간 로그 (Ctrl+C로 종료)..."
        tail -f "${TOMCAT_HOME}/logs/catalina.out"
        ;;
    check)
        echo "============================================="
        echo " DLM 환경 점검"
        echo "============================================="
        echo ""
        echo "── Java ──"
        "${TOMCAT_HOME}/../java/amazon-corretto-11/bin/java" -version 2>&1 || \
        java -version 2>&1 || echo "Java 없음"
        echo ""
        echo "── Tomcat ──"
        echo "CATALINA_HOME: ${TOMCAT_HOME}"
        echo "symlink: $(ls -la /opt/tomcat/latest 2>/dev/null)"
        ls "${TOMCAT_HOME}/webapps/"*.war 2>/dev/null || echo "WAR 파일 없음"
        echo ""
        echo "── 서비스 ──"
        systemctl is-enabled ${SERVICE_NAME} 2>/dev/null || echo "서비스 미등록"
        systemctl is-active ${SERVICE_NAME} 2>/dev/null || echo "서비스 미기동"
        echo ""
        echo "── 디스크 ──"
        df -h / /opt /dlmlogs /dlmapilogs 2>/dev/null | sort -u
        echo ""
        echo "── DB 연결 ──"
        mysql -u root -p -e "SELECT 'MariaDB OK' AS status; USE cotdl; SELECT COUNT(*) AS table_count FROM information_schema.tables WHERE table_schema='cotdl';" 2>/dev/null || echo "DB 연결 실패 - 수동 확인"
        echo ""
        echo "── 소유권 ──"
        stat -c '%U:%G %n' /opt/tomcat /dlmlogs /dlmapilogs 2>/dev/null
        ;;
    *)
        echo "DLM Tomcat 관리 스크립트"
        echo ""
        echo "사용법: $0 {start|stop|restart|status|log|check}"
        echo ""
        echo "  start   - Tomcat 시작"
        echo "  stop    - Tomcat 중지"
        echo "  restart - Tomcat 재시작"
        echo "  status  - 상태 + 포트 + PID + 최근 로그"
        echo "  log     - catalina.out 실시간 모니터링"
        echo "  check   - 전체 환경 점검 (Java, Tomcat, DB, 디스크)"
        exit 1
        ;;
esac
