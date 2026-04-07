import os
from dataclasses import dataclass, field
from pathlib import Path

from dotenv import load_dotenv


BACKEND_DIR = Path(__file__).resolve().parents[2]
PROJECT_DIR = BACKEND_DIR.parent
load_dotenv(BACKEND_DIR / ".env")


def _normalize_database_url(url: str) -> str:
    if url.startswith("postgres://"):
        return url.replace("postgres://", "postgresql://", 1)
    return url


@dataclass(slots=True)
class Settings:
    app_name: str = field(default_factory=lambda: os.getenv("APP_NAME", "ShopFlow API"))
    api_prefix: str = field(default_factory=lambda: os.getenv("API_PREFIX", "/api/v1"))
    secret_key: str = field(default_factory=lambda: os.getenv("SECRET_KEY", "dev-secret-key"))
    access_token_expire_minutes: int = field(
        default_factory=lambda: int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "1440"))
    )
    database_url: str = field(
        default_factory=lambda: _normalize_database_url(
            os.getenv("DATABASE_URL", "sqlite:///./shopflow.db")
        )
    )
    cors_origins: list[str] = field(
        default_factory=lambda: os.getenv(
            "CORS_ORIGINS", "http://localhost:3000,http://localhost:5173"
        )
        .replace(" ", "")
        .split(",")
    )
    upload_dir: str = field(
        default_factory=lambda: os.getenv(
            "UPLOAD_DIR",
            str(BACKEND_DIR / "app" / "static" / "uploads"),
        )
    )
    base_url: str = field(default_factory=lambda: os.getenv("BASE_URL", "http://localhost:8000"))


settings = Settings()
