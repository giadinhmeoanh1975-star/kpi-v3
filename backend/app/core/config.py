import os
from pydantic_settings import BaseSettings
from pydantic import field_validator # Import thêm cái này

class Settings(BaseSettings):
    PROJECT_NAME: str = "KPI System - Chi cục Hải quan Khu vực VIII"
    VERSION: str = "3.0.0"
    
    # Lấy giá trị gốc từ môi trường
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "postgresql+asyncpg://postgres:postgres@db:5432/kpi_db"
    )
    
    SECRET_KEY: str = os.getenv("SECRET_KEY", "kpi-system-secret-key-2025-very-long-and-secure")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours

    # --- THÊM ĐOẠN NÀY ĐỂ FIX LỖI RENDER ---
    @field_validator("DATABASE_URL", mode="before")
    def assemble_db_connection(cls, v: str | None) -> str:
        if v is None:
            return "postgresql+asyncpg://postgres:postgres@db:5432/kpi_db"
        
        # Render trả về "postgres://" (cũ) hoặc "postgresql://" (chuẩn sync)
        # Cần đổi sang "postgresql+asyncpg://" để chạy async
        if v.startswith("postgres://"):
            return v.replace("postgres://", "postgresql+asyncpg://", 1)
        elif v.startswith("postgresql://") and "asyncpg" not in v:
            return v.replace("postgresql://", "postgresql+asyncpg://", 1)
        
        return v
    # ---------------------------------------
    
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()