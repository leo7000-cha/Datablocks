#!/bin/bash

set -e  # 에러 발생 시 즉시 스크립트 중단

# 설정
TOMCAT_SERVICE="tomcat"
WEBAPPS_DIR="/opt/tomcat/latest/webapps"
DLM_DIR="$WEBAPPS_DIR/DLM"
WAR_SOURCE="/datablocks/DLM.war"
WAR_FILE="$DLM_DIR/DLM.war"

echo "=== DLM Deploy Script Start ==="

# 항상 DLM 디렉토리로 이동
echo "[Info] Changing directory to $DLM_DIR"
cd "$DLM_DIR"

# Tomcat 서비스 정지
echo "[Info] Stopping Tomcat service: $TOMCAT_SERVICE"
systemctl stop "$TOMCAT_SERVICE"

# application.properties 파일 백업
if [ -f "$DLM_DIR/WEB-INF/classes/application.properties" ]; then
    cp "$DLM_DIR/WEB-INF/classes/application.properties" "$DLM_DIR/application.properties.backup"
    echo "[Info] application.properties backed up."
else
    echo "[Warn] application.properties not found. Skipping backup."
fi

# logback-local.xml 파일 백업
if [ -f "$DLM_DIR/WEB-INF/classes/logback-local.xml" ]; then
    cp "$DLM_DIR/WEB-INF/classes/logback-local.xml" "$DLM_DIR/logback-local.xml.backup"
    echo "[Info] logback-local.xml backed up."
else
    echo "[Warn] logback-local.xml not found. Skipping backup."
fi

# 백업 파일 권한 설정
chmod 776 "$DLM_DIR"/*.backup || true

# 기존 파일 삭제
echo "[Info] Removing old application files..."
rm -rf "$DLM_DIR/resources" "$DLM_DIR/WEB-INF" "$DLM_DIR/META-INF" "$WAR_FILE" || true

# 새 DLM.war 복사
echo "[Info] Copying new DLM.war to $DLM_DIR"
cp "$WAR_SOURCE" "$WAR_FILE"

# DLM.war 압축 해제
echo "[Info] Extracting DLM.war..."
jar xf "$WAR_FILE"
rm -f "$WAR_FILE"

# 소유자 및 권한 설정
echo "[Info] Changing ownership and permissions..."
chown -R tomcat: /opt/tomcat
chmod 776 "$DLM_DIR/WEB-INF/classes/"{logback-local.xml,application.properties}

# application.properties 복원
if [ -f "$DLM_DIR/application.properties.backup" ]; then
    cp "$DLM_DIR/application.properties.backup" "$DLM_DIR/WEB-INF/classes/application.properties"
    echo "[Info] application.properties restored."
fi

# logback-local.xml 복원
if [ -f "$DLM_DIR/logback-local.xml.backup" ]; then
    cp "$DLM_DIR/logback-local.xml.backup" "$DLM_DIR/WEB-INF/classes/logback-local.xml"
    echo "[Info] logback-local.xml restored."
fi

# Tomcat 서비스 시작
echo "[Info] Starting Tomcat service: $TOMCAT_SERVICE"
systemctl start "$TOMCAT_SERVICE"

echo "=== DLM Deploy Script Completed Successfully ==="
