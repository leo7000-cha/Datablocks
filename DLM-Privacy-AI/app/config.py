"""DLM Privacy AI - Configuration"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "DLM-Privacy-AI"
    app_version: str = "1.0.0"
    debug: bool = False

    # MariaDB — 환경변수 필수 주입 (이미지 내부 평문 금지 정책)
    #   PRIVACY_AI_DB_HOST / _PORT / _NAME / _USER / _PASSWORD
    db_host: str
    db_port: int = 3306
    db_name: str
    db_user: str
    db_password: str

    # DLM API
    dlm_api_url: str = "http://dlm:8080"

    # LLM Settings
    llm_enabled: bool = False
    llm_api_url: str = ""
    llm_api_key: str = ""
    llm_model: str = ""
    llm_timeout: int = 60
    llm_max_tokens: int = 4096
    llm_temperature: float = 0.1
    llm_sample_count: int = 5

    class Config:
        env_prefix = "PRIVACY_AI_"


settings = Settings()
