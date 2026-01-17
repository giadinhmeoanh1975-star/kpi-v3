import hashlib
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.config import settings
from app.core.database import get_db
from app.models import NguoiDung, ChucVu, DonVi

security = HTTPBearer()

def hash_password(password: str) -> str:
    """Hash password using SHA256"""
    return hashlib.sha256(password.encode()).hexdigest()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify password"""
    return hash_password(plain_password) == hashed_password

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """Create JWT access token"""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db)
) -> NguoiDung:
    """Get current user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Không thể xác thực thông tin đăng nhập",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        token = credentials.credentials
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    result = await db.execute(select(NguoiDung).where(NguoiDung.id == user_id))
    user = result.scalar_one_or_none()
    
    if user is None:
        raise credentials_exception
    if not user.trang_thai:
        raise HTTPException(status_code=403, detail="Tài khoản đã bị khóa")
    return user

async def get_user_info(user: NguoiDung, db: AsyncSession) -> dict:
    """Get detailed user info including don_vi and chuc_vu"""
    # Get chức vụ
    chuc_vu = None
    if user.chuc_vu_id:
        result = await db.execute(select(ChucVu).where(ChucVu.id == user.chuc_vu_id))
        chuc_vu = result.scalar_one_or_none()
    
    # Get đơn vị
    don_vi = None
    if user.don_vi_id:
        result = await db.execute(select(DonVi).where(DonVi.id == user.don_vi_id))
        don_vi = result.scalar_one_or_none()
    
    return {
        "id": str(user.id),
        "ma_cong_chuc": user.ma_cong_chuc,
        "ho_ten": user.ho_ten,
        "don_vi_id": str(user.don_vi_id) if user.don_vi_id else None,
        "don_vi_ten": don_vi.ten_don_vi if don_vi else None,
        "don_vi_ma": don_vi.ma_don_vi if don_vi else None,
        "chuc_vu_id": str(user.chuc_vu_id) if user.chuc_vu_id else None,
        "chuc_vu_ten": chuc_vu.ten_chuc_vu if chuc_vu else None,
        "chuc_vu_ma": chuc_vu.ma_chuc_vu if chuc_vu else None,
        "la_lanh_dao": chuc_vu.la_lanh_dao if chuc_vu else False,
        "cap_lanh_dao": chuc_vu.cap_lanh_dao if chuc_vu else 0,
        "co_the_phe_duyet": chuc_vu.co_the_phe_duyet if chuc_vu else False,
        "la_admin": user.la_admin,
        "la_tccb": user.la_tccb
    }
