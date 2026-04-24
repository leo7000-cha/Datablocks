# ==============================================================================
# DLM-Privacy-AI FastAPI Service Dockerfile
# Python 3.11 + FastAPI + Uvicorn
# ==============================================================================

FROM python:3.11-slim AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# --- Runtime ---
FROM python:3.11-slim

LABEL maintainer="Datablocks"
LABEL description="DLM Privacy AI Service"

WORKDIR /app

# Create non-root user
RUN groupadd -r privacyai && useradd -r -g privacyai -d /app -s /sbin/nologin privacyai

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY app/ /app/app/

RUN mkdir -p /app/logs /app/models && chown -R privacyai:privacyai /app

USER privacyai

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app

EXPOSE 8000

# HEALTHCHECK 제거 — 호스트에서 외부 포트 체크(컨테이너 내부 쉘/curl/wget 미사용 정책)

CMD ["uvicorn", "app.main:app", \
     "--host", "0.0.0.0", \
     "--port", "8000", \
     "--workers", "4", \
     "--limit-concurrency", "100", \
     "--timeout-keep-alive", "30"]
