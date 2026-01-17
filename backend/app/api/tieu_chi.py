"""
API tiêu chí chung - Chấm điểm tiêu chí chung hàng tháng
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from datetime import date
from typing import Optional
from pydantic import BaseModel

from ..core.database import get_db
from ..core.security import get_current_user
from ..models import NguoiDung, TieuChiChung

router = APIRouter(prefix="/tieu-chi", tags=["Tiêu chí chung"])

class TieuChiCreate(BaseModel):
    nguoi_duoc_cham_id: int
    thang: int
    nam: int
    diem_cham_cong: float = 6.0  # Tối đa 6 điểm
    diem_chanh_tri_tu_tuong: float = 6.0  # Tối đa 6 điểm
    diem_hoc_tap_boi_duong: float = 6.0  # Tối đa 6 điểm
    diem_ky_luat_ky_cuong: float = 6.0  # Tối đa 6 điểm
    diem_phong_cach_thai_do: float = 6.0  # Tối đa 6 điểm
    ghi_chu: Optional[str] = None

class TieuChiUpdate(BaseModel):
    diem_cham_cong: Optional[float] = None
    diem_chanh_tri_tu_tuong: Optional[float] = None
    diem_hoc_tap_boi_duong: Optional[float] = None
    diem_ky_luat_ky_cuong: Optional[float] = None
    diem_phong_cach_thai_do: Optional[float] = None
    ghi_chu: Optional[str] = None


@router.get("/cua-toi")
async def get_my_tieu_chi(
    thang: Optional[int] = None,
    nam: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy tiêu chí chung của bản thân"""
    query = select(TieuChiChung).where(
        TieuChiChung.nguoi_duoc_cham_id == current_user.id
    )
    
    if thang:
        query = query.where(TieuChiChung.thang == thang)
    if nam:
        query = query.where(TieuChiChung.nam == nam)
    
    query = query.order_by(TieuChiChung.nam.desc(), TieuChiChung.thang.desc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "thang": r.thang,
        "nam": r.nam,
        "diem_cham_cong": r.diem_cham_cong,
        "diem_chanh_tri_tu_tuong": r.diem_chanh_tri_tu_tuong,
        "diem_hoc_tap_boi_duong": r.diem_hoc_tap_boi_duong,
        "diem_ky_luat_ky_cuong": r.diem_ky_luat_ky_cuong,
        "diem_phong_cach_thai_do": r.diem_phong_cach_thai_do,
        "tong_diem": r.tong_diem,
        "ghi_chu": r.ghi_chu,
        "nguoi_cham_ten": r.nguoi_cham.ho_ten if r.nguoi_cham else None,
        "ngay_tao": r.ngay_tao.isoformat() if r.ngay_tao else None
    } for r in records]


@router.get("/danh-sach")
async def get_tieu_chi_list(
    don_vi_id: Optional[int] = None,
    thang: Optional[int] = None,
    nam: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy danh sách tiêu chí chung - chỉ lãnh đạo mới xem được"""
    if current_user.cap_lanh_dao > 4:
        raise HTTPException(status_code=403, detail="Không có quyền xem danh sách tiêu chí chung")
    
    query = select(TieuChiChung).join(NguoiDung, TieuChiChung.nguoi_duoc_cham_id == NguoiDung.id)
    
    # Lãnh đạo cấp 3,4 chỉ xem được trong đơn vị
    if current_user.cap_lanh_dao >= 3:
        query = query.where(NguoiDung.don_vi_id == current_user.don_vi_id)
    elif don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    
    if thang:
        query = query.where(TieuChiChung.thang == thang)
    if nam:
        query = query.where(TieuChiChung.nam == nam)
    
    query = query.order_by(TieuChiChung.nam.desc(), TieuChiChung.thang.desc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "nguoi_duoc_cham_id": r.nguoi_duoc_cham_id,
        "nguoi_duoc_cham_ten": r.nguoi_duoc_cham.ho_ten if r.nguoi_duoc_cham else None,
        "thang": r.thang,
        "nam": r.nam,
        "tong_diem": r.tong_diem,
        "nguoi_cham_ten": r.nguoi_cham.ho_ten if r.nguoi_cham else None,
        "ngay_tao": r.ngay_tao.isoformat() if r.ngay_tao else None
    } for r in records]


@router.get("/nguoi-co-the-cham")
async def get_nguoi_co_the_cham(
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy danh sách người mà user hiện tại có thể chấm tiêu chí chung"""
    if current_user.cap_lanh_dao > 4:
        return []
    
    query = select(NguoiDung).where(
        NguoiDung.trang_thai == True,
        NguoiDung.id != current_user.id
    )
    
    # Cấp 3,4: chấm trong đơn vị
    if current_user.cap_lanh_dao >= 3:
        query = query.where(
            NguoiDung.don_vi_id == current_user.don_vi_id,
            NguoiDung.cap_lanh_dao > current_user.cap_lanh_dao
        )
    # Cấp 1,2: chấm tất cả cấp dưới
    else:
        query = query.where(NguoiDung.cap_lanh_dao > current_user.cap_lanh_dao)
    
    query = query.order_by(NguoiDung.don_vi_id, NguoiDung.cap_lanh_dao, NguoiDung.ho_ten)
    
    result = await db.execute(query)
    users = result.scalars().all()
    
    return [{
        "id": u.id,
        "ho_ten": u.ho_ten,
        "don_vi_ten": u.don_vi.ten if u.don_vi else None,
        "chuc_vu_ten": u.chuc_vu.ten if u.chuc_vu else None
    } for u in users]


@router.post("")
async def create_tieu_chi(
    data: TieuChiCreate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Chấm tiêu chí chung cho nhân viên"""
    if current_user.cap_lanh_dao > 4:
        raise HTTPException(status_code=403, detail="Không có quyền chấm tiêu chí chung")
    
    # Validate điểm
    for field, value in [
        ("diem_cham_cong", data.diem_cham_cong),
        ("diem_chanh_tri_tu_tuong", data.diem_chanh_tri_tu_tuong),
        ("diem_hoc_tap_boi_duong", data.diem_hoc_tap_boi_duong),
        ("diem_ky_luat_ky_cuong", data.diem_ky_luat_ky_cuong),
        ("diem_phong_cach_thai_do", data.diem_phong_cach_thai_do)
    ]:
        if value < 0 or value > 6:
            raise HTTPException(status_code=400, detail=f"{field} phải từ 0-6 điểm")
    
    # Kiểm tra người được chấm
    nguoi_duoc_cham = await db.get(NguoiDung, data.nguoi_duoc_cham_id)
    if not nguoi_duoc_cham:
        raise HTTPException(status_code=404, detail="Không tìm thấy người được chấm")
    
    # Kiểm tra quyền chấm
    if current_user.cap_lanh_dao >= nguoi_duoc_cham.cap_lanh_dao:
        raise HTTPException(status_code=403, detail="Không có quyền chấm người này")
    
    if current_user.cap_lanh_dao >= 3 and nguoi_duoc_cham.don_vi_id != current_user.don_vi_id:
        raise HTTPException(status_code=403, detail="Không có quyền chấm người khác đơn vị")
    
    # Kiểm tra đã chấm chưa
    existing = await db.execute(
        select(TieuChiChung).where(
            TieuChiChung.nguoi_duoc_cham_id == data.nguoi_duoc_cham_id,
            TieuChiChung.thang == data.thang,
            TieuChiChung.nam == data.nam
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Đã có điểm tiêu chí chung cho tháng này")
    
    # Tính tổng điểm
    tong_diem = (
        data.diem_cham_cong + 
        data.diem_chanh_tri_tu_tuong + 
        data.diem_hoc_tap_boi_duong + 
        data.diem_ky_luat_ky_cuong + 
        data.diem_phong_cach_thai_do
    )
    
    tieu_chi = TieuChiChung(
        nguoi_duoc_cham_id=data.nguoi_duoc_cham_id,
        nguoi_cham_id=current_user.id,
        thang=data.thang,
        nam=data.nam,
        diem_cham_cong=data.diem_cham_cong,
        diem_chanh_tri_tu_tuong=data.diem_chanh_tri_tu_tuong,
        diem_hoc_tap_boi_duong=data.diem_hoc_tap_boi_duong,
        diem_ky_luat_ky_cuong=data.diem_ky_luat_ky_cuong,
        diem_phong_cach_thai_do=data.diem_phong_cach_thai_do,
        tong_diem=tong_diem,
        ghi_chu=data.ghi_chu
    )
    
    db.add(tieu_chi)
    await db.commit()
    await db.refresh(tieu_chi)
    
    return {"message": "Chấm tiêu chí chung thành công", "id": tieu_chi.id, "tong_diem": tong_diem}


@router.put("/{id}")
async def update_tieu_chi(
    id: int,
    data: TieuChiUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Cập nhật tiêu chí chung"""
    tieu_chi = await db.get(TieuChiChung, id)
    if not tieu_chi:
        raise HTTPException(status_code=404, detail="Không tìm thấy tiêu chí")
    
    if tieu_chi.nguoi_cham_id != current_user.id and current_user.cap_lanh_dao > 2:
        raise HTTPException(status_code=403, detail="Không có quyền sửa")
    
    update_data = data.dict(exclude_unset=True)
    for field, value in update_data.items():
        if field.startswith("diem_") and (value < 0 or value > 6):
            raise HTTPException(status_code=400, detail=f"{field} phải từ 0-6 điểm")
        setattr(tieu_chi, field, value)
    
    # Tính lại tổng điểm
    tieu_chi.tong_diem = (
        tieu_chi.diem_cham_cong + 
        tieu_chi.diem_chanh_tri_tu_tuong + 
        tieu_chi.diem_hoc_tap_boi_duong + 
        tieu_chi.diem_ky_luat_ky_cuong + 
        tieu_chi.diem_phong_cach_thai_do
    )
    
    await db.commit()
    
    return {"message": "Cập nhật thành công", "tong_diem": tieu_chi.tong_diem}


@router.delete("/{id}")
async def delete_tieu_chi(
    id: int,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Xóa tiêu chí chung - chỉ admin hoặc người tạo"""
    tieu_chi = await db.get(TieuChiChung, id)
    if not tieu_chi:
        raise HTTPException(status_code=404, detail="Không tìm thấy tiêu chí")
    
    if tieu_chi.nguoi_cham_id != current_user.id and current_user.cap_lanh_dao > 1:
        raise HTTPException(status_code=403, detail="Không có quyền xóa")
    
    await db.delete(tieu_chi)
    await db.commit()
    
    return {"message": "Xóa thành công"}
