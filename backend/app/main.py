"""
KPI Management System v3.0
Chi cục Hải quan Khu vực VIII
"""
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import logging

from .core.config import settings
from .core.database import engine
from .models import Base

# Import routers
from .api.auth import router as auth_router
from .api.danh_muc import router as danh_muc_router
from .api.ke_khai import router as ke_khai_router
from .api.phe_duyet import router as phe_duyet_router
from .api.nhiem_vu import router as nhiem_vu_router
from .api.tieu_chi import router as tieu_chi_router
from .api.nghi_phep import router as nghi_phep_router
from .api.kpi import router as kpi_router
from .api.admin import router as admin_router

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    logger.info("Starting KPI System v3.0...")
    # Create tables (for development)
    # async with engine.begin() as conn:
    #     await conn.run_sync(Base.metadata.create_all)
    logger.info("KPI System started successfully")
    yield
    logger.info("Shutting down KPI System...")


app = FastAPI(
    title="KPI Management System",
    description="Hệ thống quản lý KPI - Chi cục Hải quan Khu vực VIII",
    version="3.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Lỗi hệ thống. Vui lòng thử lại sau."}
    )


# Include routers
app.include_router(auth_router, prefix="/api")
app.include_router(danh_muc_router, prefix="/api")
app.include_router(ke_khai_router, prefix="/api")
app.include_router(phe_duyet_router, prefix="/api")
app.include_router(nhiem_vu_router, prefix="/api")
app.include_router(tieu_chi_router, prefix="/api")
app.include_router(nghi_phep_router, prefix="/api")
app.include_router(kpi_router, prefix="/api")
app.include_router(admin_router, prefix="/api")


# Health check endpoint
@app.get("/health")
async def health_check():
    return {"status": "healthy", "version": "3.0.0"}


@app.get("/")
async def root():
    return {
        "message": "KPI Management System v3.0",
        "organization": "Chi cục Hải quan Khu vực VIII",
        "docs": "/docs",
        "redoc": "/redoc"
    }


# API Info
@app.get("/api")
async def api_info():
    return {
        "version": "3.0.0",
        "endpoints": {
            "auth": "/api/auth - Đăng nhập, đổi mật khẩu",
            "danh_muc": "/api/danh-muc - Danh mục hệ thống",
            "ke_khai": "/api/ke-khai - Kê khai sản phẩm",
            "phe_duyet": "/api/phe-duyet - Phê duyệt kê khai",
            "nhiem_vu": "/api/nhiem-vu - Giao nhiệm vụ",
            "tieu_chi": "/api/tieu-chi - Tiêu chí chung",
            "nghi_phep": "/api/nghi-phep - Nghỉ phép",
            "kpi": "/api/kpi - Tính KPI",
            "admin": "/api/admin - Quản trị"
        }
    }
