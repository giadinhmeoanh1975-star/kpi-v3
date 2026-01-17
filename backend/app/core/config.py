import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "KPI System - Chi cục Hải quan Khu vực VIII"
    VERSION: str = "3.0.0"
    
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "postgresql+asyncpg://postgres:postgres@db:5432/kpi_db"
    )
    
    SECRET_KEY: str = os.getenv("SECRET_KEY", "kpi-system-secret-key-2025-very-long-and-secure")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    
    class Config:
        env_file = ".env"

settings = Settings()
