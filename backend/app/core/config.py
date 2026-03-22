from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # App
    APP_NAME: str = "Society Management App"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False

    # Database — must be set in .env
    DATABASE_URL: str

    # JWT — must be set in .env (use: openssl rand -hex 32)
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # Uploads
    UPLOAD_DIR: str = "uploads"
    MAX_IMAGE_SIZE_MB: int = 5

    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 60


settings = Settings()
