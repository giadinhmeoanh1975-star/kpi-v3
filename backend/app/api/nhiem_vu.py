from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from datetime import datetime, date
from app.core.database import get_db
from app.core.security import get_current_user
from app.models import NhiemVu, NguoiDung, ChucVu, DonVi, SanPham, MucDo

router = APIRouter(prefix="/nhiem-vu", tags=["Nhiệm vụ / Giao việc"])

class NhiemVuCreate(BaseModel):
    nguoi_nhan_id: UUID
    thang: int
    nam: int
    noi_dung: str
    san_pham_id: Optional[UUID] = None
    muc_do_id: Optional[UUID] = None
    han_hoan_thanh: Optional[date] = None
    ket_qua_mong_doi: Optional[str] = None

class NhiemVuUpdate(BaseModel):
    noi_dung: Optional[str] = None
    san_pham_id: Optional[UUID] = None
    muc_do_id: Optional[UUID] = None
    han_hoan_thanh: Optional[date] = None
    ket_qua_mong_doi: Optional[str] = None

class TuDanhGiaRequest(BaseModel):
    tu_danh_gia_hoan_thanh: str  # HOAN_THANH, CHUA_HOAN_THANH, DANG_THUC_HIEN
    tu_danh_gia_tien_do: str  # DAT, KHONG_DAT
    tu_danh_gia_chat_luong: str  # DAT, KHONG_DAT
    tu_danh_gia_ghi_chu: Optional[str] = None

class DanhGiaRequest(BaseModel):
    danh_gia_hoan_thanh: str
    danh_gia_tien_do: str
    danh_gia_chat_luong: str
    so_lan_khong_dat_tien_do: int = 0
    so_lan_khong_dat_chat_luong: int = 0
    danh_gia_ghi_chu: Optional[str] = None

async def get_user_cap(user: NguoiDung, db: AsyncSession) -> int:
    if not user.chuc_vu_id:
        return 6
    cv_result = await db.execute(select(ChucVu).where(ChucVu.id == user.chuc_vu_id))
    chuc_vu = cv_result.scalar_one_or_none()
    return chuc_vu.cap_lanh_dao if chuc_vu else 6

@router.get("/da-giao")
async def get_nhiem_vu_da_giao(
    thang: int,
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách nhiệm vụ đã giao cho người khác"""
    query = select(
        NhiemVu, NguoiDung.ho_ten, NguoiDung.ma_cong_chuc,
        ChucVu.ten_chuc_vu, SanPham.ten_san_pham, MucDo.ten_muc_do
    ).join(
        NguoiDung, NhiemVu.nguoi_nhan_id == NguoiDung.id
    ).outerjoin(
        ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
    ).outerjoin(
        SanPham, NhiemVu.san_pham_id == SanPham.id
    ).outerjoin(
        MucDo, NhiemVu.muc_do_id == MucDo.id
    ).where(
        and_(
            NhiemVu.nguoi_giao_id == current_user.id,
            NhiemVu.thang == thang,
            NhiemVu.nam == nam
        )
    ).order_by(NhiemVu.ngay_tao.desc())
    
    result = await db.execute(query)
    items = []
    for row in result.all():
        nv, nd_ten, nd_ma, cv_ten, sp_ten, md_ten = row
        items.append({
            "id": str(nv.id),
            "nguoi_nhan_ten": nd_ten,
            "nguoi_nhan_ma": nd_ma,
            "chuc_vu": cv_ten,
            "noi_dung": nv.noi_dung,
            "san_pham_ten": sp_ten,
            "muc_do_ten": md_ten,
            "han_hoan_thanh": nv.han_hoan_thanh.isoformat() if nv.han_hoan_thanh else None,
            "ket_qua_mong_doi": nv.ket_qua_mong_doi,
            "tu_danh_gia_hoan_thanh": nv.tu_danh_gia_hoan_thanh,
            "tu_danh_gia_tien_do": nv.tu_danh_gia_tien_do,
            "tu_danh_gia_chat_luong": nv.tu_danh_gia_chat_luong,
            "tu_danh_gia_ghi_chu": nv.tu_danh_gia_ghi_chu,
            "danh_gia_hoan_thanh": nv.danh_gia_hoan_thanh,
            "danh_gia_tien_do": nv.danh_gia_tien_do,
            "danh_gia_chat_luong": nv.danh_gia_chat_luong,
            "danh_gia_ghi_chu": nv.danh_gia_ghi_chu,
            "trang_thai": nv.trang_thai,
            "ngay_tao": nv.ngay_tao.isoformat() if nv.ngay_tao else None
        })
    return items

@router.get("/duoc-giao")
async def get_nhiem_vu_duoc_giao(
    thang: int,
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách nhiệm vụ được giao cho mình"""
    query = select(
        NhiemVu, NguoiDung.ho_ten, NguoiDung.ma_cong_chuc,
        ChucVu.ten_chuc_vu, SanPham.ten_san_pham, MucDo.ten_muc_do
    ).join(
        NguoiDung, NhiemVu.nguoi_giao_id == NguoiDung.id
    ).outerjoin(
        ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
    ).outerjoin(
        SanPham, NhiemVu.san_pham_id == SanPham.id
    ).outerjoin(
        MucDo, NhiemVu.muc_do_id == MucDo.id
    ).where(
        and_(
            NhiemVu.nguoi_nhan_id == current_user.id,
            NhiemVu.thang == thang,
            NhiemVu.nam == nam
        )
    ).order_by(NhiemVu.ngay_tao.desc())
    
    result = await db.execute(query)
    items = []
    for row in result.all():
        nv, nd_ten, nd_ma, cv_ten, sp_ten, md_ten = row
        items.append({
            "id": str(nv.id),
            "nguoi_giao_ten": nd_ten,
            "nguoi_giao_ma": nd_ma,
            "chuc_vu_nguoi_giao": cv_ten,
            "noi_dung": nv.noi_dung,
            "san_pham_ten": sp_ten,
            "muc_do_ten": md_ten,
            "han_hoan_thanh": nv.han_hoan_thanh.isoformat() if nv.han_hoan_thanh else None,
            "ket_qua_mong_doi": nv.ket_qua_mong_doi,
            "tu_danh_gia_hoan_thanh": nv.tu_danh_gia_hoan_thanh,
            "tu_danh_gia_tien_do": nv.tu_danh_gia_tien_do,
            "tu_danh_gia_chat_luong": nv.tu_danh_gia_chat_luong,
            "tu_danh_gia_ghi_chu": nv.tu_danh_gia_ghi_chu,
            "danh_gia_hoan_thanh": nv.danh_gia_hoan_thanh,
            "danh_gia_tien_do": nv.danh_gia_tien_do,
            "danh_gia_chat_luong": nv.danh_gia_chat_luong,
            "danh_gia_ghi_chu": nv.danh_gia_ghi_chu,
            "trang_thai": nv.trang_thai,
            "ngay_tao": nv.ngay_tao.isoformat() if nv.ngay_tao else None
        })
    return items

@router.get("/nguoi-co-the-giao")
async def get_nguoi_co_the_giao(
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách người có thể giao việc
    
    Quy tắc:
    - Cấp 4: giao cho cấp 5,6 cùng đơn vị
    - Cấp 3: giao cho cấp 4,5,6 cùng đơn vị
    - Cấp 2: giao cho cấp 3 (toàn chi cục)
    - Cấp 1: giao cho cấp 2,3 (toàn chi cục)
    """
    my_cap = await get_user_cap(current_user, db)
    
    if my_cap > 4:
        return []
    
    items = []
    
    if my_cap in [3, 4]:  # Trưởng/Phó phòng: giao cho cấp dưới cùng đơn vị
        target_caps = [5, 6] if my_cap == 4 else [4, 5, 6]
        query = select(NguoiDung, ChucVu.ten_chuc_vu).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                NguoiDung.don_vi_id == current_user.don_vi_id,
                ChucVu.cap_lanh_dao.in_(target_caps),
                NguoiDung.id != current_user.id,
                NguoiDung.trang_thai == True
            )
        ).order_by(ChucVu.thu_tu, NguoiDung.ho_ten)
    
    elif my_cap == 2:  # PCCT: giao cho cấp 3
        query = select(NguoiDung, ChucVu.ten_chuc_vu, DonVi.ten_don_vi).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).outerjoin(
            DonVi, NguoiDung.don_vi_id == DonVi.id
        ).where(
            and_(
                ChucVu.cap_lanh_dao == 3,
                NguoiDung.trang_thai == True
            )
        ).order_by(DonVi.thu_tu, NguoiDung.ho_ten)
    
    elif my_cap == 1:  # CCT: giao cho cấp 2,3
        query = select(NguoiDung, ChucVu.ten_chuc_vu, DonVi.ten_don_vi).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).outerjoin(
            DonVi, NguoiDung.don_vi_id == DonVi.id
        ).where(
            and_(
                ChucVu.cap_lanh_dao.in_([2, 3]),
                NguoiDung.trang_thai == True
            )
        ).order_by(ChucVu.thu_tu, DonVi.thu_tu, NguoiDung.ho_ten)
    
    else:
        return []
    
    result = await db.execute(query)
    for row in result.all():
        if len(row) == 2:
            nd, cv_ten = row
            dv_ten = None
        else:
            nd, cv_ten, dv_ten = row
        items.append({
            "id": str(nd.id),
            "ma_cong_chuc": nd.ma_cong_chuc,
            "ho_ten": nd.ho_ten,
            "chuc_vu": cv_ten,
            "don_vi": dv_ten
        })
    
    return items

@router.post("")
async def create_nhiem_vu(
    data: NhiemVuCreate,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Tạo nhiệm vụ / giao việc"""
    my_cap = await get_user_cap(current_user, db)
    
    if my_cap > 4:
        raise HTTPException(status_code=403, detail="Bạn không có quyền giao việc")
    
    nhiem_vu = NhiemVu(
        nguoi_giao_id=current_user.id,
        nguoi_nhan_id=data.nguoi_nhan_id,
        thang=data.thang,
        nam=data.nam,
        noi_dung=data.noi_dung,
        san_pham_id=data.san_pham_id,
        muc_do_id=data.muc_do_id,
        han_hoan_thanh=data.han_hoan_thanh,
        ket_qua_mong_doi=data.ket_qua_mong_doi,
        trang_thai="MOI_GIAO"
    )
    db.add(nhiem_vu)
    await db.commit()
    await db.refresh(nhiem_vu)
    
    return {"id": str(nhiem_vu.id), "message": "Giao việc thành công"}

@router.put("/{id}")
async def update_nhiem_vu(
    id: str,
    data: NhiemVuUpdate,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Cập nhật nhiệm vụ"""
    result = await db.execute(
        select(NhiemVu).where(
            and_(
                NhiemVu.id == id,
                NhiemVu.nguoi_giao_id == current_user.id
            )
        )
    )
    nhiem_vu = result.scalar_one_or_none()
    
    if not nhiem_vu:
        raise HTTPException(status_code=404, detail="Không tìm thấy nhiệm vụ")
    
    if nhiem_vu.trang_thai == "DA_DANH_GIA":
        raise HTTPException(status_code=400, detail="Không thể sửa nhiệm vụ đã đánh giá")
    
    update_data = data.dict(exclude_unset=True)
    for key, value in update_data.items():
        if value is not None:
            setattr(nhiem_vu, key, value)
    
    nhiem_vu.ngay_cap_nhat = datetime.utcnow()
    await db.commit()
    
    return {"message": "Cập nhật thành công"}

@router.delete("/{id}")
async def delete_nhiem_vu(
    id: str,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Xóa / hủy nhiệm vụ"""
    result = await db.execute(
        select(NhiemVu).where(
            and_(
                NhiemVu.id == id,
                NhiemVu.nguoi_giao_id == current_user.id
            )
        )
    )
    nhiem_vu = result.scalar_one_or_none()
    
    if not nhiem_vu:
        raise HTTPException(status_code=404, detail="Không tìm thấy nhiệm vụ")
    
    if nhiem_vu.trang_thai == "DA_DANH_GIA":
        raise HTTPException(status_code=400, detail="Không thể xóa nhiệm vụ đã đánh giá")
    
    nhiem_vu.trang_thai = "HUY"
    await db.commit()
    
    return {"message": "Đã hủy nhiệm vụ"}

@router.post("/{id}/tu-danh-gia")
async def tu_danh_gia(
    id: str,
    data: TuDanhGiaRequest,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Người nhận tự đánh giá nhiệm vụ"""
    result = await db.execute(
        select(NhiemVu).where(
            and_(
                NhiemVu.id == id,
                NhiemVu.nguoi_nhan_id == current_user.id
            )
        )
    )
    nhiem_vu = result.scalar_one_or_none()
    
    if not nhiem_vu:
        raise HTTPException(status_code=404, detail="Không tìm thấy nhiệm vụ")
    
    if nhiem_vu.trang_thai == "DA_DANH_GIA":
        raise HTTPException(status_code=400, detail="Nhiệm vụ đã được đánh giá")
    
    nhiem_vu.tu_danh_gia_hoan_thanh = data.tu_danh_gia_hoan_thanh
    nhiem_vu.tu_danh_gia_tien_do = data.tu_danh_gia_tien_do
    nhiem_vu.tu_danh_gia_chat_luong = data.tu_danh_gia_chat_luong
    nhiem_vu.tu_danh_gia_ghi_chu = data.tu_danh_gia_ghi_chu
    nhiem_vu.trang_thai = "CHO_DANH_GIA"
    nhiem_vu.ngay_cap_nhat = datetime.utcnow()
    
    await db.commit()
    
    return {"message": "Đã gửi tự đánh giá"}

@router.post("/{id}/danh-gia")
async def danh_gia_nhiem_vu(
    id: str,
    data: DanhGiaRequest,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lãnh đạo đánh giá nhiệm vụ"""
    result = await db.execute(
        select(NhiemVu).where(
            and_(
                NhiemVu.id == id,
                NhiemVu.nguoi_giao_id == current_user.id
            )
        )
    )
    nhiem_vu = result.scalar_one_or_none()
    
    if not nhiem_vu:
        raise HTTPException(status_code=404, detail="Không tìm thấy nhiệm vụ")
    
    if nhiem_vu.trang_thai == "DA_DANH_GIA":
        raise HTTPException(status_code=400, detail="Nhiệm vụ đã được đánh giá")
    
    nhiem_vu.danh_gia_hoan_thanh = data.danh_gia_hoan_thanh
    nhiem_vu.danh_gia_tien_do = data.danh_gia_tien_do
    nhiem_vu.danh_gia_chat_luong = data.danh_gia_chat_luong
    nhiem_vu.so_lan_khong_dat_tien_do = data.so_lan_khong_dat_tien_do
    nhiem_vu.so_lan_khong_dat_chat_luong = data.so_lan_khong_dat_chat_luong
    nhiem_vu.danh_gia_ghi_chu = data.danh_gia_ghi_chu
    nhiem_vu.trang_thai = "DA_DANH_GIA"
    nhiem_vu.ngay_cap_nhat = datetime.utcnow()
    
    await db.commit()
    
    return {"message": "Đã đánh giá nhiệm vụ"}
