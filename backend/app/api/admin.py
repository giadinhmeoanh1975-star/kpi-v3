"""
API Admin - Quản trị hệ thống và chức năng TCCB
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, update, delete
from datetime import date, datetime
from typing import Optional, List
from pydantic import BaseModel
import hashlib

from ..core.database import get_db
from ..core.security import get_current_user
from ..models import (
    NguoiDung, DonVi, ChucVu, SanPham, MucDo, HeSo,
    KeKhai, TieuChiChung, KPIThang, NghiPhep, TruongHopDacBiet,
    LogHeThong
)

router = APIRouter(prefix="/admin", tags=["Admin"])


def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


def require_admin_or_tccb(current_user: NguoiDung):
    """Kiểm tra quyền admin hoặc TCCB"""
    is_admin = current_user.tai_khoan == "admin"
    is_tccb = current_user.don_vi_id == 3  # Phòng TCCB
    is_lanh_dao = current_user.cap_lanh_dao <= 2  # CCT, PCCT
    
    if not (is_admin or is_tccb or is_lanh_dao):
        raise HTTPException(status_code=403, detail="Không có quyền truy cập")
    return True


# === QUẢN LÝ NGƯỜI DÙNG ===

class NguoiDungCreate(BaseModel):
    tai_khoan: str
    mat_khau: str = "123456"
    ho_ten: str
    don_vi_id: int
    chuc_vu_id: int
    email: Optional[str] = None
    so_dien_thoai: Optional[str] = None

class NguoiDungUpdate(BaseModel):
    ho_ten: Optional[str] = None
    don_vi_id: Optional[int] = None
    chuc_vu_id: Optional[int] = None
    email: Optional[str] = None
    so_dien_thoai: Optional[str] = None
    trang_thai: Optional[bool] = None


@router.get("/nguoi-dung")
async def get_all_nguoi_dung(
    don_vi_id: Optional[int] = None,
    trang_thai: Optional[bool] = None,
    search: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy danh sách tất cả người dùng"""
    require_admin_or_tccb(current_user)
    
    query = select(NguoiDung)
    
    if don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    if trang_thai is not None:
        query = query.where(NguoiDung.trang_thai == trang_thai)
    if search:
        query = query.where(
            NguoiDung.ho_ten.ilike(f"%{search}%") | 
            NguoiDung.tai_khoan.ilike(f"%{search}%")
        )
    
    query = query.order_by(NguoiDung.don_vi_id, NguoiDung.cap_lanh_dao, NguoiDung.ho_ten)
    
    result = await db.execute(query)
    users = result.scalars().all()
    
    return [{
        "id": u.id,
        "tai_khoan": u.tai_khoan,
        "ho_ten": u.ho_ten,
        "don_vi_id": u.don_vi_id,
        "don_vi_ten": u.don_vi.ten if u.don_vi else None,
        "chuc_vu_id": u.chuc_vu_id,
        "chuc_vu_ten": u.chuc_vu.ten if u.chuc_vu else None,
        "cap_lanh_dao": u.cap_lanh_dao,
        "email": u.email,
        "so_dien_thoai": u.so_dien_thoai,
        "trang_thai": u.trang_thai,
        "ngay_tao": u.ngay_tao.isoformat() if u.ngay_tao else None
    } for u in users]


@router.post("/nguoi-dung")
async def create_nguoi_dung(
    data: NguoiDungCreate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Tạo người dùng mới"""
    require_admin_or_tccb(current_user)
    
    # Kiểm tra tài khoản đã tồn tại
    existing = await db.execute(
        select(NguoiDung).where(NguoiDung.tai_khoan == data.tai_khoan)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Tài khoản đã tồn tại")
    
    # Lấy cấp lãnh đạo từ chức vụ
    chuc_vu = await db.get(ChucVu, data.chuc_vu_id)
    if not chuc_vu:
        raise HTTPException(status_code=404, detail="Chức vụ không tồn tại")
    
    nguoi_dung = NguoiDung(
        tai_khoan=data.tai_khoan,
        mat_khau=hash_password(data.mat_khau),
        ho_ten=data.ho_ten,
        don_vi_id=data.don_vi_id,
        chuc_vu_id=data.chuc_vu_id,
        cap_lanh_dao=chuc_vu.cap_lanh_dao,
        email=data.email,
        so_dien_thoai=data.so_dien_thoai,
        trang_thai=True
    )
    
    db.add(nguoi_dung)
    await db.commit()
    await db.refresh(nguoi_dung)
    
    # Log
    log = LogHeThong(
        nguoi_dung_id=current_user.id,
        hanh_dong="CREATE_USER",
        doi_tuong="nguoi_dung",
        doi_tuong_id=nguoi_dung.id,
        chi_tiet=f"Tạo tài khoản: {data.tai_khoan}"
    )
    db.add(log)
    await db.commit()
    
    return {"message": "Tạo người dùng thành công", "id": nguoi_dung.id}


@router.put("/nguoi-dung/{id}")
async def update_nguoi_dung(
    id: int,
    data: NguoiDungUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Cập nhật thông tin người dùng"""
    require_admin_or_tccb(current_user)
    
    nguoi_dung = await db.get(NguoiDung, id)
    if not nguoi_dung:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng")
    
    update_data = data.dict(exclude_unset=True)
    
    # Nếu đổi chức vụ, cập nhật cấp lãnh đạo
    if "chuc_vu_id" in update_data:
        chuc_vu = await db.get(ChucVu, update_data["chuc_vu_id"])
        if chuc_vu:
            nguoi_dung.cap_lanh_dao = chuc_vu.cap_lanh_dao
    
    for field, value in update_data.items():
        setattr(nguoi_dung, field, value)
    
    await db.commit()
    
    return {"message": "Cập nhật thành công"}


@router.post("/nguoi-dung/{id}/reset-password")
async def reset_password(
    id: int,
    new_password: str = "123456",
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Reset mật khẩu người dùng"""
    require_admin_or_tccb(current_user)
    
    nguoi_dung = await db.get(NguoiDung, id)
    if not nguoi_dung:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng")
    
    nguoi_dung.mat_khau = hash_password(new_password)
    await db.commit()
    
    return {"message": "Đặt lại mật khẩu thành công"}


# === TRƯỜNG HỢP ĐẶC BIỆT ===

class TruongHopDacBietCreate(BaseModel):
    nguoi_dung_id: int
    thang: int
    nam: int
    loai: str  # NGHI_DAI_HAN, CONG_TAC_DAI_HAN, DIEU_DONG, etc.
    ly_do: str
    tu_ngay: date
    den_ngay: Optional[date] = None
    xep_loai_mac_dinh: Optional[str] = None  # Xếp loại mặc định nếu có


@router.get("/truong-hop-dac-biet")
async def get_truong_hop_dac_biet(
    thang: Optional[int] = None,
    nam: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy danh sách trường hợp đặc biệt"""
    require_admin_or_tccb(current_user)
    
    query = select(TruongHopDacBiet)
    
    if thang:
        query = query.where(TruongHopDacBiet.thang == thang)
    if nam:
        query = query.where(TruongHopDacBiet.nam == nam)
    
    query = query.order_by(TruongHopDacBiet.ngay_tao.desc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "nguoi_dung_id": r.nguoi_dung_id,
        "nguoi_dung_ten": r.nguoi_dung.ho_ten if r.nguoi_dung else None,
        "don_vi_ten": r.nguoi_dung.don_vi.ten if r.nguoi_dung and r.nguoi_dung.don_vi else None,
        "thang": r.thang,
        "nam": r.nam,
        "loai": r.loai,
        "ly_do": r.ly_do,
        "tu_ngay": r.tu_ngay.isoformat() if r.tu_ngay else None,
        "den_ngay": r.den_ngay.isoformat() if r.den_ngay else None,
        "xep_loai_mac_dinh": r.xep_loai_mac_dinh,
        "nguoi_tao_ten": r.nguoi_tao.ho_ten if r.nguoi_tao else None,
        "ngay_tao": r.ngay_tao.isoformat() if r.ngay_tao else None
    } for r in records]


@router.post("/truong-hop-dac-biet")
async def create_truong_hop_dac_biet(
    data: TruongHopDacBietCreate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Tạo trường hợp đặc biệt"""
    require_admin_or_tccb(current_user)
    
    # Kiểm tra người dùng
    nguoi_dung = await db.get(NguoiDung, data.nguoi_dung_id)
    if not nguoi_dung:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng")
    
    truong_hop = TruongHopDacBiet(
        nguoi_dung_id=data.nguoi_dung_id,
        thang=data.thang,
        nam=data.nam,
        loai=data.loai,
        ly_do=data.ly_do,
        tu_ngay=data.tu_ngay,
        den_ngay=data.den_ngay,
        xep_loai_mac_dinh=data.xep_loai_mac_dinh,
        nguoi_tao_id=current_user.id
    )
    
    db.add(truong_hop)
    await db.commit()
    await db.refresh(truong_hop)
    
    return {"message": "Tạo trường hợp đặc biệt thành công", "id": truong_hop.id}


@router.delete("/truong-hop-dac-biet/{id}")
async def delete_truong_hop_dac_biet(
    id: int,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Xóa trường hợp đặc biệt"""
    require_admin_or_tccb(current_user)
    
    truong_hop = await db.get(TruongHopDacBiet, id)
    if not truong_hop:
        raise HTTPException(status_code=404, detail="Không tìm thấy trường hợp đặc biệt")
    
    await db.delete(truong_hop)
    await db.commit()
    
    return {"message": "Xóa thành công"}


# === ĐIỂM LÃNH ĐẠO ===

class DiemLanhDaoCreate(BaseModel):
    nguoi_duoc_cham_id: int
    thang: int
    nam: int
    xep_loai: str  # D, Đ, E
    ghi_chu: Optional[str] = None


@router.post("/diem-lanh-dao")
async def create_diem_lanh_dao(
    data: DiemLanhDaoCreate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Chấm điểm lãnh đạo"""
    if current_user.cap_lanh_dao > 2:
        raise HTTPException(status_code=403, detail="Chỉ CCT/PCCT mới có quyền chấm điểm lãnh đạo")
    
    if data.xep_loai not in ["D", "Đ", "E"]:
        raise HTTPException(status_code=400, detail="Xếp loại không hợp lệ (D, Đ, E)")
    
    from ..models import DiemLanhDao
    
    # Kiểm tra đã chấm chưa
    existing = await db.execute(
        select(DiemLanhDao).where(
            DiemLanhDao.nguoi_duoc_cham_id == data.nguoi_duoc_cham_id,
            DiemLanhDao.nguoi_cham_id == current_user.id,
            DiemLanhDao.thang == data.thang,
            DiemLanhDao.nam == data.nam
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Đã chấm điểm cho người này trong tháng")
    
    diem = DiemLanhDao(
        nguoi_duoc_cham_id=data.nguoi_duoc_cham_id,
        nguoi_cham_id=current_user.id,
        thang=data.thang,
        nam=data.nam,
        xep_loai=data.xep_loai,
        ghi_chu=data.ghi_chu
    )
    
    db.add(diem)
    await db.commit()
    
    return {"message": "Chấm điểm lãnh đạo thành công"}


# === THỐNG KÊ ===

@router.get("/thong-ke/tong-quan")
async def thong_ke_tong_quan(
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Thống kê tổng quan hệ thống"""
    require_admin_or_tccb(current_user)
    
    # Đếm người dùng theo đơn vị
    user_count = await db.execute(
        select(DonVi.ten, func.count(NguoiDung.id))
        .join(NguoiDung, DonVi.id == NguoiDung.don_vi_id)
        .where(NguoiDung.trang_thai == True)
        .group_by(DonVi.id, DonVi.ten)
    )
    by_don_vi = {row[0]: row[1] for row in user_count.all()}
    
    # Đếm theo chức vụ
    cv_count = await db.execute(
        select(ChucVu.ten, func.count(NguoiDung.id))
        .join(NguoiDung, ChucVu.id == NguoiDung.chuc_vu_id)
        .where(NguoiDung.trang_thai == True)
        .group_by(ChucVu.id, ChucVu.ten)
    )
    by_chuc_vu = {row[0]: row[1] for row in cv_count.all()}
    
    # Tổng số kê khai tháng này
    today = date.today()
    ke_khai_count = await db.execute(
        select(func.count(KeKhai.id))
        .where(KeKhai.thang == today.month, KeKhai.nam == today.year)
    )
    tong_ke_khai = ke_khai_count.scalar() or 0
    
    # Kê khai chờ duyệt
    cho_duyet_count = await db.execute(
        select(func.count(KeKhai.id))
        .where(
            KeKhai.thang == today.month, 
            KeKhai.nam == today.year,
            KeKhai.trang_thai == "CHO_DUYET"
        )
    )
    cho_duyet = cho_duyet_count.scalar() or 0
    
    return {
        "tong_nguoi_dung": sum(by_don_vi.values()),
        "theo_don_vi": by_don_vi,
        "theo_chuc_vu": by_chuc_vu,
        "thang_hien_tai": {
            "thang": today.month,
            "nam": today.year,
            "tong_ke_khai": tong_ke_khai,
            "cho_duyet": cho_duyet
        }
    }


@router.get("/thong-ke/ke-khai")
async def thong_ke_ke_khai(
    thang: Optional[int] = None,
    nam: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Thống kê kê khai theo trạng thái"""
    require_admin_or_tccb(current_user)
    
    today = date.today()
    thang = thang or today.month
    nam = nam or today.year
    
    # Đếm theo trạng thái
    result = await db.execute(
        select(KeKhai.trang_thai, func.count(KeKhai.id))
        .where(KeKhai.thang == thang, KeKhai.nam == nam)
        .group_by(KeKhai.trang_thai)
    )
    by_status = {row[0]: row[1] for row in result.all()}
    
    # Đếm theo đơn vị
    result = await db.execute(
        select(DonVi.ten, func.count(KeKhai.id))
        .join(NguoiDung, KeKhai.nguoi_dung_id == NguoiDung.id)
        .join(DonVi, NguoiDung.don_vi_id == DonVi.id)
        .where(KeKhai.thang == thang, KeKhai.nam == nam)
        .group_by(DonVi.id, DonVi.ten)
    )
    by_don_vi = {row[0]: row[1] for row in result.all()}
    
    return {
        "thang": thang,
        "nam": nam,
        "theo_trang_thai": by_status,
        "theo_don_vi": by_don_vi
    }


# === LOG HỆ THỐNG ===

@router.get("/log")
async def get_log(
    nguoi_dung_id: Optional[int] = None,
    hanh_dong: Optional[str] = None,
    tu_ngay: Optional[date] = None,
    den_ngay: Optional[date] = None,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy log hệ thống"""
    if current_user.tai_khoan != "admin":
        raise HTTPException(status_code=403, detail="Chỉ admin mới xem được log")
    
    query = select(LogHeThong)
    
    if nguoi_dung_id:
        query = query.where(LogHeThong.nguoi_dung_id == nguoi_dung_id)
    if hanh_dong:
        query = query.where(LogHeThong.hanh_dong == hanh_dong)
    if tu_ngay:
        query = query.where(LogHeThong.ngay_tao >= tu_ngay)
    if den_ngay:
        query = query.where(LogHeThong.ngay_tao <= den_ngay)
    
    query = query.order_by(LogHeThong.ngay_tao.desc()).limit(limit)
    
    result = await db.execute(query)
    logs = result.scalars().all()
    
    return [{
        "id": l.id,
        "nguoi_dung_id": l.nguoi_dung_id,
        "nguoi_dung_ten": l.nguoi_dung.ho_ten if l.nguoi_dung else None,
        "hanh_dong": l.hanh_dong,
        "doi_tuong": l.doi_tuong,
        "doi_tuong_id": l.doi_tuong_id,
        "chi_tiet": l.chi_tiet,
        "ip_address": l.ip_address,
        "ngay_tao": l.ngay_tao.isoformat() if l.ngay_tao else None
    } for l in logs]


# === QUẢN LÝ DANH MỤC ===

@router.post("/danh-muc/san-pham")
async def create_san_pham(
    ma: str,
    ten: str,
    mo_ta: Optional[str] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Thêm loại sản phẩm mới"""
    require_admin_or_tccb(current_user)
    
    sp = SanPham(ma=ma, ten=ten, mo_ta=mo_ta, trang_thai=True)
    db.add(sp)
    await db.commit()
    await db.refresh(sp)
    
    return {"message": "Thêm sản phẩm thành công", "id": sp.id}


@router.post("/danh-muc/cap-nhat-he-so")
async def cap_nhat_he_so(
    san_pham_id: int,
    muc_do_id: int,
    he_so: float,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Cập nhật hệ số quy đổi"""
    require_admin_or_tccb(current_user)
    
    existing = await db.execute(
        select(HeSo).where(
            HeSo.san_pham_id == san_pham_id,
            HeSo.muc_do_id == muc_do_id
        )
    )
    hs = existing.scalar_one_or_none()
    
    if hs:
        hs.he_so = he_so
    else:
        hs = HeSo(san_pham_id=san_pham_id, muc_do_id=muc_do_id, he_so=he_so)
        db.add(hs)
    
    await db.commit()
    
    return {"message": "Cập nhật hệ số thành công"}
