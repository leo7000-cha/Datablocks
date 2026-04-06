"""DLM Privacy AI - Configuration"""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "DLM-Privacy-AI"
    app_version: str = "1.0.0"
    debug: bool = False

    # MariaDB
    db_host: str = "dlm-mariadb"
    db_port: int = 3306
    db_name: str = "cotdl"
    db_user: str = "dlm"
    db_password: str = "dlm_password"

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
