"""DLM Privacy AI - PII Detection Request/Response Models"""

from pydantic import BaseModel


class ColumnInfo(BaseModel):
    name: str
    type: str
    comment: str = ""
    samples: list[str] = []


class DetectRequest(BaseModel):
    table_name: str
    schema_name: str = ""
    columns: list[ColumnInfo]


class ColumnResult(BaseModel):
    column: str
    pii_type: str | None = None
    score: int = 0
    reason: str = ""


class DetectResponse(BaseModel):
    status: str
    table_name: str
    results: list[ColumnResult] = []
    token_usage: int = 0
    elapsed_ms: int = 0


class LlmStatusResponse(BaseModel):
    enabled: bool
    connected: bool = False
    model: str = ""
    api_url: str = ""
    error: str = ""
