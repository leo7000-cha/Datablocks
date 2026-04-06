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

# Copy WAR from builder
COPY --from=builder /build/build/libs/*.war /app/DLM.war
RUN chown dlm:dlm /app/DLM.war

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

HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD wget --no-verbose --tries=1 -O /dev/null http://localhost:8080/ || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/DLM.war"]
