#!/bin/bash

set -e  # 에러 발생 시 즉시 스크립트 중단

# 설정
TOMCAT_BASE_DIR="/opt/tomcat"
TOMCAT_REAL_VERSION="apache-tomcat-9.0.87_api"  # ★ 실제 설치된 Tomcat 디렉토리 이름 (필요시 수정)
TOMCAT_LINK_NAME="latestapi"                # ★ 사용할 심볼릭 링크 이름
TOMCAT_SERVICE="tomcatapi"                   # ★ systemctl에 등록된 Tomcat 서비스 이름
WEBAPPS_DIR="$TOMCAT_BASE_DIR/$TOMCAT_LINK_NAME/webapps"
DLM_DIR="$WEBAPPS_DIR/DLM"
WAR_SOURCE="/datablocks/DLMAPI.war"
WAR_FILE="$DLM_DIR/DLMAPI.war"

echo "=== DLM API Deploy Script Start ==="

# Tomcat 심볼릭 링크 존재 확인 및 생성
TOMCAT_REAL_DIR="$TOMCAT_BASE_DIR/$TOMCAT_REAL_VERSION"
TOMCAT_LINK="$TOMCAT_BASE_DIR/$TOMCAT_LINK_NAME"

if [ ! -e "$TOMCAT_LINK" ]; then
    echo "[Info] Tomcat symbolic link not found. Creating symbolic link: $TOMCAT_LINK -> $TOMCAT_REAL_DIR"
    ln -s "$TOMCAT_REAL_DIR" "$TOMCAT_LINK"
else
    echo "[Info] Tomcat symbolic link already exists: $TOMCAT_LINK"
fi

# 항상 DLM 디렉토리로 이동
echo "[Info] Changing directory to $DLM_DIR"
mkdir -p "$DLM_DIR"  # 디렉토리가 없으면 생성
cd "$DLM_DIR"

# Tomcat 서비스 정지
echo "[Info] Stopping Tomcat service: $TOMCAT_SERVICE"
systemctl stop "$TOMCAT_SERVICE"

# application.properties 백업
if [ -f "$DLM_DIR/WEB-INF/classes/application.properties" ]; then
    cp "$DLM_DIR/WEB-INF/classes/application.properties" "$DLM_DIR/application.properties.backup"
    echo "[Info] application.properties backed up."
else
    echo "[Warn] application.properties not found. Skipping backup."
fi

# logback-local.xml 백업
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

# 새 DLMAPI.war 복사
echo "[Info] Copying new DLMAPI.war to $DLM_DIR"
cp "$WAR_SOURCE" "$WAR_FILE"

# DLMAPI.war 압축 해제
echo "[Info] Extracting DLMAPI.war..."
jar xf "$WAR_FILE"
rm -f "$WAR_FILE"

# 소유자 및 권한 설정
echo "[Info] Changing ownership and permissions..."
chown -R tomcat: "$TOMCAT_BASE_DIR"
chmod 776 "$DLM_DIR/WEB-INF/classes/"{logback-local.xml,application.properties} || true

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

echo "=== DLM API Deploy Script Completed Successfully ==="

