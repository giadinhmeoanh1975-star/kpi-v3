from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from decimal import Decimal
from app.core.database import get_db
from app.core.security import get_current_user
from app.models import (
    KeKhai, SanPham, MucDo, HeSo, NguoiDung, ChucVu, DonVi
)

router = APIRouter(prefix="/ke-khai", tags=["Kê khai công việc"])

class KeKhaiCreate(BaseModel):
    thang: int
    nam: int
    san_pham_id: UUID
    so_luong: int = 1
    ket_qua: Optional[str] = None
    muc_do_id: UUID
    he_so: Optional[float] = None
    he_so_tu_nhap: Optional[float] = None
    tien_do: str = "DAT"
    chat_luong: str = "DAT"
    so_lan_khong_dat_tien_do: int = 0
    so_lan_khong_dat_chat_luong: int = 0
    lanh_dao_giao_viec_id: Optional[UUID] = None
    lanh_dao_phe_duyet_id: Optional[UUID] = None  # THÊM: Lãnh đạo phê duyệt (phó phòng/đội)
    ghi_chu: Optional[str] = None

class KeKhaiUpdate(BaseModel):
    san_pham_id: Optional[UUID] = None
    so_luong: Optional[int] = None
    ket_qua: Optional[str] = None
    muc_do_id: Optional[UUID] = None
    he_so: Optional[float] = None
    he_so_tu_nhap: Optional[float] = None
    tien_do: Optional[str] = None
    chat_luong: Optional[str] = None
    so_lan_khong_dat_tien_do: Optional[int] = None
    so_lan_khong_dat_chat_luong: Optional[int] = None
    lanh_dao_giao_viec_id: Optional[UUID] = None
    lanh_dao_phe_duyet_id: Optional[UUID] = None
    ghi_chu: Optional[str] = None

class PheDuyetRequest(BaseModel):
    trang_thai: str  # DA_DUYET, TU_CHOI, YEU_CAU_SUA
    ly_do_tu_choi: Optional[str] = None
    chat_luong: Optional[str] = None  # Có thể đánh giá lại chất lượng
    tien_do: Optional[str] = None

@router.get("/cua-toi")
async def get_ke_khai_cua_toi(
    thang: int, 
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách kê khai của bản thân"""
    query = select(
        KeKhai, 
        SanPham.ten_san_pham, 
        SanPham.ma_san_pham,
        SanPham.don_vi_tinh,
        MucDo.ten_muc_do,
        MucDo.ma_muc_do
    ).outerjoin(
        SanPham, KeKhai.san_pham_id == SanPham.id
    ).outerjoin(
        MucDo, KeKhai.muc_do_id == MucDo.id
    ).where(
        and_(
            KeKhai.nguoi_dung_id == current_user.id,
            KeKhai.thang == thang,
            KeKhai.nam == nam
        )
    ).order_by(KeKhai.ngay_tao.desc())
    
    result = await db.execute(query)
    items = []
    for row in result.all():
        kk, sp_ten, sp_ma, sp_dvt, md_ten, md_ma = row
        
        # Lấy tên lãnh đạo phê duyệt
        ld_phe_duyet_ten = None
        if kk.lanh_dao_phe_duyet_id:
            ld_result = await db.execute(
                select(NguoiDung.ho_ten).where(NguoiDung.id == kk.lanh_dao_phe_duyet_id)
            )
            ld_phe_duyet_ten = ld_result.scalar_one_or_none()
        
        items.append({
            "id": str(kk.id),
            "thang": kk.thang,
            "nam": kk.nam,
            "san_pham_id": str(kk.san_pham_id) if kk.san_pham_id else None,
            "san_pham_ten": sp_ten,
            "san_pham_ma": sp_ma,
            "don_vi_tinh": sp_dvt,
            "so_luong": kk.so_luong,
            "ket_qua": kk.ket_qua,
            "muc_do_id": str(kk.muc_do_id) if kk.muc_do_id else None,
            "muc_do_ten": md_ten,
            "muc_do_ma": md_ma,
            "he_so": float(kk.he_so) if kk.he_so else None,
            "he_so_tu_nhap": float(kk.he_so_tu_nhap) if kk.he_so_tu_nhap else None,
            "tien_do": kk.tien_do,
            "chat_luong": kk.chat_luong,
            "so_lan_khong_dat_tien_do": kk.so_lan_khong_dat_tien_do,
            "so_lan_khong_dat_chat_luong": kk.so_lan_khong_dat_chat_luong,
            "lanh_dao_phe_duyet_id": str(kk.lanh_dao_phe_duyet_id) if kk.lanh_dao_phe_duyet_id else None,
            "lanh_dao_phe_duyet_ten": ld_phe_duyet_ten,
            "trang_thai": kk.trang_thai,
            "ly_do_tu_choi": kk.ly_do_tu_choi,
            "ghi_chu": kk.ghi_chu,
            "ngay_tao": kk.ngay_tao.isoformat() if kk.ngay_tao else None
        })
    return items

@router.post("")
async def create_ke_khai(
    data: KeKhaiCreate,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Tạo kê khai công việc mới"""
    # Kiểm tra mức độ cho phép tự nhập hệ số
    md_result = await db.execute(select(MucDo).where(MucDo.id == data.muc_do_id))
    muc_do = md_result.scalar_one_or_none()
    
    # Lấy hệ số từ danh mục nếu không nhập
    he_so = data.he_so
    if not he_so and not (muc_do and muc_do.cho_phep_tu_nhap_he_so):
        hs_result = await db.execute(
            select(HeSo).where(
                and_(
                    HeSo.san_pham_id == data.san_pham_id,
                    HeSo.muc_do_id == data.muc_do_id
                )
            )
        )
        hs = hs_result.scalar_one_or_none()
        he_so = float(hs.he_so) if hs else 1.0
    
    ke_khai = KeKhai(
        nguoi_dung_id=current_user.id,
        thang=data.thang,
        nam=data.nam,
        san_pham_id=data.san_pham_id,
        so_luong=data.so_luong,
        ket_qua=data.ket_qua,
        muc_do_id=data.muc_do_id,
        he_so=Decimal(str(he_so)) if he_so else None,
        he_so_tu_nhap=Decimal(str(data.he_so_tu_nhap)) if data.he_so_tu_nhap else None,
        tien_do=data.tien_do,
        chat_luong=data.chat_luong,
        so_lan_khong_dat_tien_do=data.so_lan_khong_dat_tien_do,
        so_lan_khong_dat_chat_luong=data.so_lan_khong_dat_chat_luong,
        lanh_dao_giao_viec_id=data.lanh_dao_giao_viec_id,
        lanh_dao_phe_duyet_id=data.lanh_dao_phe_duyet_id,
        ghi_chu=data.ghi_chu,
        trang_thai="NHAP"
    )
    db.add(ke_khai)
    await db.commit()
    await db.refresh(ke_khai)
    
    return {"id": str(ke_khai.id), "message": "Tạo kê khai thành công"}

@router.put("/{id}")
async def update_ke_khai(
    id: str,
    data: KeKhaiUpdate,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Cập nhật kê khai"""
    result = await db.execute(
        select(KeKhai).where(
            and_(
                KeKhai.id == id,
                KeKhai.nguoi_dung_id == current_user.id
            )
        )
    )
    ke_khai = result.scalar_one_or_none()
    
    if not ke_khai:
        raise HTTPException(status_code=404, detail="Không tìm thấy kê khai")
    
    if ke_khai.trang_thai not in ["NHAP", "TU_CHOI", "YEU_CAU_SUA"]:
        raise HTTPException(status_code=400, detail="Không thể sửa kê khai đã gửi duyệt")
    
    # Cập nhật các trường
    update_data = data.dict(exclude_unset=True)
    for key, value in update_data.items():
        if value is not None:
            if key in ['he_so', 'he_so_tu_nhap']:
                setattr(ke_khai, key, Decimal(str(value)) if value else None)
            else:
                setattr(ke_khai, key, value)
    
    # Reset trạng thái nếu đang bị từ chối
    if ke_khai.trang_thai in ["TU_CHOI", "YEU_CAU_SUA"]:
        ke_khai.trang_thai = "NHAP"
        ke_khai.ly_do_tu_choi = None
    
    ke_khai.ngay_cap_nhat = datetime.utcnow()
    await db.commit()
    
    return {"message": "Cập nhật thành công"}

@router.delete("/{id}")
async def delete_ke_khai(
    id: str,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Xóa kê khai"""
    result = await db.execute(
        select(KeKhai).where(
            and_(
                KeKhai.id == id,
                KeKhai.nguoi_dung_id == current_user.id
            )
        )
    )
    ke_khai = result.scalar_one_or_none()
    
    if not ke_khai:
        raise HTTPException(status_code=404, detail="Không tìm thấy kê khai")
    
    if ke_khai.trang_thai not in ["NHAP", "TU_CHOI", "YEU_CAU_SUA"]:
        raise HTTPException(status_code=400, detail="Không thể xóa kê khai đã gửi duyệt")
    
    await db.delete(ke_khai)
    await db.commit()
    
    return {"message": "Đã xóa kê khai"}

@router.post("/gui")
async def gui_ke_khai(
    thang: int, 
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Gửi tất cả kê khai trong tháng để phê duyệt"""
    result = await db.execute(
        select(KeKhai).where(
            and_(
                KeKhai.nguoi_dung_id == current_user.id,
                KeKhai.thang == thang,
                KeKhai.nam == nam,
                KeKhai.trang_thai.in_(["NHAP", "TU_CHOI", "YEU_CAU_SUA"])
            )
        )
    )
    ke_khais = result.scalars().all()
    
    if not ke_khais:
        raise HTTPException(status_code=400, detail="Không có kê khai nào để gửi")
    
    # Kiểm tra xem có chọn lãnh đạo phê duyệt chưa
    for kk in ke_khais:
        if not kk.lanh_dao_phe_duyet_id:
            raise HTTPException(
                status_code=400, 
                detail="Vui lòng chọn lãnh đạo phê duyệt cho tất cả kê khai"
            )
    
    for kk in ke_khais:
        kk.trang_thai = "CHO_DUYET"
        kk.ngay_cap_nhat = datetime.utcnow()
    
    await db.commit()
    
    return {"message": f"Đã gửi {len(ke_khais)} kê khai để phê duyệt"}

@router.get("/thong-ke")
async def thong_ke_ke_khai(
    thang: int,
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Thống kê kê khai trong tháng"""
    result = await db.execute(
        select(KeKhai).where(
            and_(
                KeKhai.nguoi_dung_id == current_user.id,
                KeKhai.thang == thang,
                KeKhai.nam == nam
            )
        )
    )
    ke_khais = result.scalars().all()
    
    tong_san_pham = 0
    tong_he_so = 0.0
    trang_thai_count = {"NHAP": 0, "CHO_DUYET": 0, "DA_DUYET": 0, "TU_CHOI": 0, "YEU_CAU_SUA": 0}
    
    for kk in ke_khais:
        tong_san_pham += kk.so_luong or 0
        he_so_su_dung = float(kk.he_so_tu_nhap or kk.he_so or 1)
        tong_he_so += (kk.so_luong or 0) * he_so_su_dung
        if kk.trang_thai in trang_thai_count:
            trang_thai_count[kk.trang_thai] += 1
    
    return {
        "thang": thang,
        "nam": nam,
        "tong_ke_khai": len(ke_khais),
        "tong_san_pham": tong_san_pham,
        "tong_he_so": round(tong_he_so, 2),
        "trang_thai": trang_thai_count
    }
