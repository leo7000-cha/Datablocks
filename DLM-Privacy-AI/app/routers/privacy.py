"""DLM Privacy AI - PII Detection Router"""

import logging
import time

from fastapi import APIRouter

from app.config import settings
from app.schemas.detect import (
    ColumnResult,
    DetectRequest,
    DetectResponse,
    LlmStatusResponse,
)
from app.services import llm_service

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/api/v1/privacy/detect", response_model=DetectResponse)
async def detect_pii(request: DetectRequest):
    """Detect PII in table columns using LLM."""
    start = time.time()

    if not settings.llm_enabled:
        return DetectResponse(
            status="disabled",
            table_name=request.table_name,
            results=[
                ColumnResult(column=col.name, pii_type=None, score=0, reason="AI disabled")
                for col in request.columns
            ],
        )

    results, token_usage = await llm_service.detect(request)
    elapsed_ms = int((time.time() - start) * 1000)

    return DetectResponse(
        status="success",
        table_name=request.table_name,
        results=results,
        token_usage=token_usage,
        elapsed_ms=elapsed_ms,
    )


@router.get("/api/v1/privacy/llm-status", response_model=LlmStatusResponse)
async def llm_status():
    """Check LLM API connection status."""
    status = await llm_service.check_connection()
    return LlmStatusResponse(
        enabled=settings.llm_enabled,
        connected=status["connected"],
        model=status["model"],
        api_url=settings.llm_api_url,
        error=status["error"],
    )
