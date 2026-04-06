"""DLM Privacy AI - LLM API Service for PII Detection"""

import json
import logging
import time

from openai import AsyncOpenAI, APIConnectionError, APITimeoutError

from app.config import settings
from app.schemas.detect import ColumnResult, DetectRequest

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """당신은 데이터베이스 개인정보 탐지 전문가입니다.
테이블의 컬럼 정보(이름, 타입, 코멘트, 샘플 데이터)를 분석하여
각 컬럼이 개인정보에 해당하는지 판별하세요.

개인정보 유형:
- PERSON_NAME: 성명
- SSN: 주민등록번호
- PHONE: 전화번호/휴대전화
- EMAIL: 이메일 주소
- ADDRESS: 주소
- BIRTH_DATE: 생년월일
- ACCOUNT_NO: 계좌번호
- CARD_NO: 카드번호
- PASSPORT: 여권번호
- DRIVER_LICENSE: 운전면허번호
- IP_ADDRESS: IP 주소
- OTHER_PII: 기타 개인정보

각 컬럼에 대해 JSON 배열로 응답하세요:
[{"column":"컬럼명","pii_type":"유형코드 또는 null","score":0-100,"reason":"판단근거 20자이내"}]

PII가 아닌 컬럼은 score: 0, pii_type: null로 응답하세요.
반드시 JSON만 응답하세요. 설명이나 마크다운 없이 순수 JSON만."""


def _build_user_prompt(request: DetectRequest) -> str:
    """Build user prompt from detect request."""
    data = {
        "table": request.table_name,
        "columns": [
            {
                "name": col.name,
                "type": col.type,
                "comment": col.comment,
                "samples": col.samples[: settings.llm_sample_count],
            }
            for col in request.columns
        ],
    }
    return json.dumps(data, ensure_ascii=False)


def _parse_llm_response(content: str, columns: list[str]) -> list[ColumnResult]:
    """Parse LLM response JSON into ColumnResult list."""
    # Strip markdown code fences if present
    text = content.strip()
    if text.startswith("```"):
        lines = text.split("\n")
        lines = [l for l in lines if not l.strip().startswith("```")]
        text = "\n".join(lines).strip()

    results_raw = json.loads(text)

    results = []
    parsed_columns = set()
    for item in results_raw:
        col_name = item.get("column", "")
        if col_name not in columns:
            continue
        parsed_columns.add(col_name)
        results.append(
            ColumnResult(
                column=col_name,
                pii_type=item.get("pii_type"),
                score=max(0, min(100, int(item.get("score", 0)))),
                reason=item.get("reason", ""),
            )
        )

    # Fill missing columns with score 0
    for col_name in columns:
        if col_name not in parsed_columns:
            results.append(ColumnResult(column=col_name, pii_type=None, score=0, reason=""))

    return results


def _get_client() -> AsyncOpenAI:
    """Create OpenAI-compatible async client."""
    return AsyncOpenAI(
        base_url=settings.llm_api_url,
        api_key=settings.llm_api_key or "no-key",
        timeout=settings.llm_timeout,
    )


async def detect(request: DetectRequest) -> tuple[list[ColumnResult], int]:
    """Call LLM API to detect PII in table columns.

    Returns:
        tuple of (results, token_usage)
    """
    column_names = [col.name for col in request.columns]
    user_prompt = _build_user_prompt(request)

    logger.info(
        "LLM detect: table=%s, columns=%d, prompt_len=%d",
        request.table_name,
        len(request.columns),
        len(user_prompt),
    )

    client = _get_client()
    try:
        response = await client.chat.completions.create(
            model=settings.llm_model,
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_prompt},
            ],
            temperature=settings.llm_temperature,
            max_tokens=settings.llm_max_tokens,
        )

        content = response.choices[0].message.content or ""
        token_usage = response.usage.total_tokens if response.usage else 0

        logger.info(
            "LLM response: table=%s, tokens=%d, content_len=%d",
            request.table_name,
            token_usage,
            len(content),
        )

        results = _parse_llm_response(content, column_names)
        return results, token_usage

    except (APIConnectionError, APITimeoutError) as e:
        logger.error("LLM API connection error for table %s: %s", request.table_name, e)
        return [ColumnResult(column=c, pii_type=None, score=0, reason="") for c in column_names], 0
    except json.JSONDecodeError as e:
        logger.error("LLM response parse error for table %s: %s", request.table_name, e)
        return [ColumnResult(column=c, pii_type=None, score=0, reason="") for c in column_names], 0
    except Exception as e:
        logger.error("LLM detect error for table %s: %s", request.table_name, e)
        return [ColumnResult(column=c, pii_type=None, score=0, reason="") for c in column_names], 0


async def check_connection() -> dict:
    """Check LLM API connection status."""
    if not settings.llm_enabled:
        return {"connected": False, "model": "", "error": "LLM disabled"}

    if not settings.llm_api_url:
        return {"connected": False, "model": "", "error": "LLM API URL not configured"}

    client = _get_client()
    try:
        response = await client.chat.completions.create(
            model=settings.llm_model,
            messages=[{"role": "user", "content": "ping"}],
            max_tokens=5,
        )
        model = response.model or settings.llm_model
        return {"connected": True, "model": model, "error": ""}
    except Exception as e:
        return {"connected": False, "model": "", "error": str(e)[:200]}
