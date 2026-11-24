from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_prefix="ANALYTICS_",
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    host: str = "127.0.0.1"
    port: int = Field(default=15700, ge=1, le=65535)
    log_level: Literal["critical", "error", "warning", "info", "debug", "trace"] = "info"


settings = Settings()
