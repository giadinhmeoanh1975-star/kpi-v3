from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel
from datetime import timedelta
from app.core.database import get_db
from app.core.security import verify_password, create_access_token, get_current_user, get_user_info
from app.core.config import settings
from app.models import NguoiDung, ChucVu, DonVi

router = APIRouter(prefix="/auth", tags=["Authentication"])

class LoginRequest(BaseModel):
    ma_cong_chuc: str
    mat_khau: str

class ChangePasswordRequest(BaseModel):
    mat_khau_cu: str
    mat_khau_moi: str

@router.post("/login")
async def login(data: LoginRequest, db: AsyncSession = Depends(get_db)):
    """Đăng nhập hệ thống"""
    # Tìm user
    result = await db.execute(
        select(NguoiDung).where(NguoiDung.ma_cong_chuc == data.ma_cong_chuc)
    )
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Mã công chức không tồn tại"
        )
    
    if not verify_password(data.mat_khau, user.mat_khau):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Mật khẩu không đúng"
        )
    
    if not user.trang_thai:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Tài khoản đã bị khóa"
        )
    
    # Tạo token
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id)}, 
        expires_delta=access_token_expires
    )
    
    # Lấy thông tin chi tiết
    user_info = await get_user_info(user, db)
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user_info
    }

@router.get("/me")
async def get_me(
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy thông tin người dùng hiện tại"""
    return await get_user_info(current_user, db)

@router.post("/change-password")
async def change_password(
    data: ChangePasswordRequest,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Đổi mật khẩu"""
    from app.core.security import hash_password
    
    if not verify_password(data.mat_khau_cu, current_user.mat_khau):
        raise HTTPException(status_code=400, detail="Mật khẩu cũ không đúng")
    
    if len(data.mat_khau_moi) < 6:
        raise HTTPException(status_code=400, detail="Mật khẩu mới phải có ít nhất 6 ký tự")
    
    current_user.mat_khau = hash_password(data.mat_khau_moi)
    await db.commit()
    
    return {"message": "Đổi mật khẩu thành công"}
