# ==============================================================================
# DLM Spring Boot Application Dockerfile
# Java 21 + Gradle 8.9 + JSP (WAR packaging)
# ==============================================================================

# --- Stage 1: Build ---
FROM gradle:8.9-jdk21 AS builder

WORKDIR /build

# Copy Gradle wrapper and config first (cache dependency layer)
COPY gradle/ gradle/
COPY gradlew settings.gradle build.gradle lombok.config ./

# Copy external libs required by build.gradle fileTree
COPY libs/ libs/

# Download dependencies (cached unless build files change)
RUN ./gradlew dependencies --no-daemon || true

# Copy source code
COPY src/ src/

# Build WAR
RUN ./gradlew bootWar --no-daemon -x test

# --- Stage 2: Runtime ---
FROM eclipse-temurin:21-jre-jammy

LABEL maintainer="Datablocks"
LABEL description="DLM - Data Lifecycle Management"

WORKDIR /app

# Create non-root user
RUN groupadd -r dlm && useradd -r -g dlm -d /app -s /sbin/nologin dlm

# Create required directories (logback → /app/logs 통일)
RUN mkdir -p /app/logs /app/upload && chown -R dlm:dlm /app

# Copy WAR from builder and explode it
# → getRealPath()가 정상 동작하도록 WAR를 디스크에 풀어서 실행 (외장 Tomcat과 동일)
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*
COPY --from=builder /build/build/libs/*.war /app/DLM.war
RUN mkdir -p /app/DLM && cd /app/DLM && unzip -q /app/DLM.war && rm /app/DLM.war
RUN chown -R dlm:dlm /app/DLM

USER dlm

# JVM options - DEV default (32GB server, 12GB container)
# PROD에서는 docker-compose.prod.yml의 JAVA_OPTS 환경변수로 오버라이드
ENV JAVA_OPTS="-Xms2g -Xmx8g \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UseContainerSupport \
    -XX:MaxRAMPercentage=70.0 \
    -XX:+HeapDumpOnOutOfMemoryError \
    -XX:HeapDumpPath=/app/logs/heapdump.hprof \
    -Djava.security.egd=file:/dev/./urandom \
    -Dfile.encoding=UTF-8 \
    -Duser.timezone=Asia/Seoul"

EXPOSE 8080

# HEALTHCHECK 제거 — 호스트에서 외부 포트 체크(컨테이너 내부 쉘/curl/wget 미사용 정책)

# Exploded WAR에서 WarLauncher로 실행 → getRealPath() 정상 동작
ENTRYPOINT ["sh", "-c", "cd /app/DLM && java $JAVA_OPTS org.springframework.boot.loader.launch.WarLauncher"]
