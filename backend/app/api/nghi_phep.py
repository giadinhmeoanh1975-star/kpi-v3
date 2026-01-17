"""
API nghỉ phép - Quản lý đơn xin nghỉ phép
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel
from enum import Enum

from ..core.database import get_db
from ..core.security import get_current_user
from ..models import NguoiDung, NghiPhep, DonVi

router = APIRouter(prefix="/nghi-phep", tags=["Nghỉ phép"])

class LoaiNghi(str, Enum):
    PHEP_NAM = "PHEP_NAM"
    VIEC_RIENG = "VIEC_RIENG"
    OM = "OM"
    THAI_SAN = "THAI_SAN"
    KHAC = "KHAC"

class TrangThaiNghi(str, Enum):
    CHO_DUYET = "CHO_DUYET"
    DA_DUYET = "DA_DUYET"
    TU_CHOI = "TU_CHOI"
    HUY = "HUY"

class NghiPhepCreate(BaseModel):
    tu_ngay: date
    den_ngay: date
    loai_nghi: LoaiNghi = LoaiNghi.PHEP_NAM
    ly_do: str
    nguoi_duyet_id: Optional[int] = None  # TCCB có thể duyệt thay lãnh đạo

class NghiPhepUpdate(BaseModel):
    tu_ngay: Optional[date] = None
    den_ngay: Optional[date] = None
    loai_nghi: Optional[LoaiNghi] = None
    ly_do: Optional[str] = None


@router.get("/cua-toi")
async def get_my_nghi_phep(
    nam: Optional[int] = None,
    trang_thai: Optional[TrangThaiNghi] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy danh sách đơn nghỉ phép của bản thân"""
    query = select(NghiPhep).where(NghiPhep.nguoi_dung_id == current_user.id)
    
    if nam:
        query = query.where(
            or_(
                NghiPhep.tu_ngay.between(date(nam, 1, 1), date(nam, 12, 31)),
                NghiPhep.den_ngay.between(date(nam, 1, 1), date(nam, 12, 31))
            )
        )
    
    if trang_thai:
        query = query.where(NghiPhep.trang_thai == trang_thai.value)
    
    query = query.order_by(NghiPhep.ngay_tao.desc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "tu_ngay": r.tu_ngay.isoformat(),
        "den_ngay": r.den_ngay.isoformat(),
        "so_ngay": r.so_ngay,
        "loai_nghi": r.loai_nghi,
        "ly_do": r.ly_do,
        "trang_thai": r.trang_thai,
        "nguoi_duyet_ten": r.nguoi_duyet.ho_ten if r.nguoi_duyet else None,
        "ly_do_tu_choi": r.ly_do_tu_choi,
        "ngay_duyet": r.ngay_duyet.isoformat() if r.ngay_duyet else None,
        "ngay_tao": r.ngay_tao.isoformat() if r.ngay_tao else None
    } for r in records]


@router.get("/cho-duyet")
async def get_nghi_phep_cho_duyet(
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy danh sách đơn nghỉ phép chờ duyệt"""
    # Kiểm tra quyền duyệt
    # TCCB (don_vi_id = 3) có quyền duyệt tất cả
    # Lãnh đạo cấp 1-4 có quyền duyệt cấp dưới
    is_tccb = current_user.don_vi_id == 3  # Phòng TCCB
    
    if not is_tccb and current_user.cap_lanh_dao > 4:
        return []
    
    query = select(NghiPhep).join(
        NguoiDung, NghiPhep.nguoi_dung_id == NguoiDung.id
    ).where(NghiPhep.trang_thai == TrangThaiNghi.CHO_DUYET.value)
    
    if is_tccb:
        # TCCB duyệt tất cả
        pass
    elif current_user.cap_lanh_dao >= 3:
        # Lãnh đạo cấp 3,4 duyệt trong đơn vị
        query = query.where(
            NguoiDung.don_vi_id == current_user.don_vi_id,
            NguoiDung.cap_lanh_dao > current_user.cap_lanh_dao
        )
    else:
        # CCT, PCCT duyệt cấp dưới
        query = query.where(NguoiDung.cap_lanh_dao > current_user.cap_lanh_dao)
    
    query = query.order_by(NghiPhep.ngay_tao.asc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "nguoi_dung_id": r.nguoi_dung_id,
        "nguoi_dung_ten": r.nguoi_dung.ho_ten if r.nguoi_dung else None,
        "don_vi_ten": r.nguoi_dung.don_vi.ten if r.nguoi_dung and r.nguoi_dung.don_vi else None,
        "tu_ngay": r.tu_ngay.isoformat(),
        "den_ngay": r.den_ngay.isoformat(),
        "so_ngay": r.so_ngay,
        "loai_nghi": r.loai_nghi,
        "ly_do": r.ly_do,
        "ngay_tao": r.ngay_tao.isoformat() if r.ngay_tao else None
    } for r in records]


@router.get("/da-duyet")
async def get_nghi_phep_da_duyet(
    don_vi_id: Optional[int] = None,
    thang: Optional[int] = None,
    nam: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy danh sách đơn nghỉ phép đã duyệt"""
    query = select(NghiPhep).join(
        NguoiDung, NghiPhep.nguoi_dung_id == NguoiDung.id
    ).where(NghiPhep.trang_thai == TrangThaiNghi.DA_DUYET.value)
    
    # Chỉ lãnh đạo hoặc TCCB mới xem được danh sách
    is_tccb = current_user.don_vi_id == 3
    if not is_tccb and current_user.cap_lanh_dao > 4:
        query = query.where(NghiPhep.nguoi_dung_id == current_user.id)
    elif current_user.cap_lanh_dao >= 3 and not is_tccb:
        query = query.where(NguoiDung.don_vi_id == current_user.don_vi_id)
    elif don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    
    if nam:
        start_date = date(nam, thang or 1, 1)
        end_date = date(nam, thang or 12, 31 if not thang else (30 if thang in [4,6,9,11] else (28 if thang == 2 else 31)))
        query = query.where(
            or_(
                NghiPhep.tu_ngay.between(start_date, end_date),
                NghiPhep.den_ngay.between(start_date, end_date)
            )
        )
    
    query = query.order_by(NghiPhep.tu_ngay.desc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "nguoi_dung_id": r.nguoi_dung_id,
        "nguoi_dung_ten": r.nguoi_dung.ho_ten if r.nguoi_dung else None,
        "don_vi_ten": r.nguoi_dung.don_vi.ten if r.nguoi_dung and r.nguoi_dung.don_vi else None,
        "tu_ngay": r.tu_ngay.isoformat(),
        "den_ngay": r.den_ngay.isoformat(),
        "so_ngay": r.so_ngay,
        "loai_nghi": r.loai_nghi,
        "ly_do": r.ly_do,
        "nguoi_duyet_ten": r.nguoi_duyet.ho_ten if r.nguoi_duyet else None,
        "ngay_duyet": r.ngay_duyet.isoformat() if r.ngay_duyet else None
    } for r in records]


@router.post("")
async def create_nghi_phep(
    data: NghiPhepCreate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Tạo đơn xin nghỉ phép"""
    if data.den_ngay < data.tu_ngay:
        raise HTTPException(status_code=400, detail="Ngày kết thúc phải sau ngày bắt đầu")
    
    # Tính số ngày nghỉ (không tính cuối tuần)
    so_ngay = 0
    current = data.tu_ngay
    while current <= data.den_ngay:
        if current.weekday() < 5:  # Thứ 2-6
            so_ngay += 1
        current = date.fromordinal(current.toordinal() + 1)
    
    if so_ngay == 0:
        raise HTTPException(status_code=400, detail="Không có ngày làm việc trong khoảng thời gian này")
    
    nghi_phep = NghiPhep(
        nguoi_dung_id=current_user.id,
        tu_ngay=data.tu_ngay,
        den_ngay=data.den_ngay,
        so_ngay=so_ngay,
        loai_nghi=data.loai_nghi.value,
        ly_do=data.ly_do,
        trang_thai=TrangThaiNghi.CHO_DUYET.value
    )
    
    db.add(nghi_phep)
    await db.commit()
    await db.refresh(nghi_phep)
    
    return {"message": "Tạo đơn nghỉ phép thành công", "id": nghi_phep.id, "so_ngay": so_ngay}


@router.put("/{id}")
async def update_nghi_phep(
    id: int,
    data: NghiPhepUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Cập nhật đơn nghỉ phép - chỉ khi chưa duyệt"""
    nghi_phep = await db.get(NghiPhep, id)
    if not nghi_phep:
        raise HTTPException(status_code=404, detail="Không tìm thấy đơn nghỉ phép")
    
    if nghi_phep.nguoi_dung_id != current_user.id:
        raise HTTPException(status_code=403, detail="Không có quyền sửa đơn này")
    
    if nghi_phep.trang_thai != TrangThaiNghi.CHO_DUYET.value:
        raise HTTPException(status_code=400, detail="Chỉ có thể sửa đơn đang chờ duyệt")
    
    update_data = data.dict(exclude_unset=True)
    
    tu_ngay = update_data.get("tu_ngay", nghi_phep.tu_ngay)
    den_ngay = update_data.get("den_ngay", nghi_phep.den_ngay)
    
    if den_ngay < tu_ngay:
        raise HTTPException(status_code=400, detail="Ngày kết thúc phải sau ngày bắt đầu")
    
    # Tính lại số ngày
    so_ngay = 0
    current = tu_ngay
    while current <= den_ngay:
        if current.weekday() < 5:
            so_ngay += 1
        current = date.fromordinal(current.toordinal() + 1)
    
    for field, value in update_data.items():
        if field == "loai_nghi":
            value = value.value if hasattr(value, "value") else value
        setattr(nghi_phep, field, value)
    
    nghi_phep.so_ngay = so_ngay
    
    await db.commit()
    
    return {"message": "Cập nhật thành công", "so_ngay": so_ngay}


@router.post("/{id}/duyet")
async def duyet_nghi_phep(
    id: int,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Duyệt đơn nghỉ phép"""
    nghi_phep = await db.get(NghiPhep, id)
    if not nghi_phep:
        raise HTTPException(status_code=404, detail="Không tìm thấy đơn nghỉ phép")
    
    if nghi_phep.trang_thai != TrangThaiNghi.CHO_DUYET.value:
        raise HTTPException(status_code=400, detail="Đơn này không ở trạng thái chờ duyệt")
    
    # Kiểm tra quyền duyệt
    nguoi_xin = await db.get(NguoiDung, nghi_phep.nguoi_dung_id)
    is_tccb = current_user.don_vi_id == 3
    
    can_approve = False
    if is_tccb:
        can_approve = True
    elif current_user.cap_lanh_dao < nguoi_xin.cap_lanh_dao:
        if current_user.cap_lanh_dao >= 3:
            can_approve = nguoi_xin.don_vi_id == current_user.don_vi_id
        else:
            can_approve = True
    
    if not can_approve:
        raise HTTPException(status_code=403, detail="Không có quyền duyệt đơn này")
    
    nghi_phep.trang_thai = TrangThaiNghi.DA_DUYET.value
    nghi_phep.nguoi_duyet_id = current_user.id
    nghi_phep.ngay_duyet = datetime.now()
    
    await db.commit()
    
    return {"message": "Duyệt đơn thành công"}


@router.post("/{id}/tu-choi")
async def tu_choi_nghi_phep(
    id: int,
    ly_do: str,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Từ chối đơn nghỉ phép"""
    nghi_phep = await db.get(NghiPhep, id)
    if not nghi_phep:
        raise HTTPException(status_code=404, detail="Không tìm thấy đơn nghỉ phép")
    
    if nghi_phep.trang_thai != TrangThaiNghi.CHO_DUYET.value:
        raise HTTPException(status_code=400, detail="Đơn này không ở trạng thái chờ duyệt")
    
    # Kiểm tra quyền duyệt (giống như duyet_nghi_phep)
    nguoi_xin = await db.get(NguoiDung, nghi_phep.nguoi_dung_id)
    is_tccb = current_user.don_vi_id == 3
    
    can_approve = False
    if is_tccb:
        can_approve = True
    elif current_user.cap_lanh_dao < nguoi_xin.cap_lanh_dao:
        if current_user.cap_lanh_dao >= 3:
            can_approve = nguoi_xin.don_vi_id == current_user.don_vi_id
        else:
            can_approve = True
    
    if not can_approve:
        raise HTTPException(status_code=403, detail="Không có quyền từ chối đơn này")
    
    nghi_phep.trang_thai = TrangThaiNghi.TU_CHOI.value
    nghi_phep.nguoi_duyet_id = current_user.id
    nghi_phep.ngay_duyet = datetime.now()
    nghi_phep.ly_do_tu_choi = ly_do
    
    await db.commit()
    
    return {"message": "Từ chối đơn thành công"}


@router.post("/{id}/huy")
async def huy_nghi_phep(
    id: int,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Hủy đơn nghỉ phép - người tạo đơn có thể hủy khi chưa duyệt"""
    nghi_phep = await db.get(NghiPhep, id)
    if not nghi_phep:
        raise HTTPException(status_code=404, detail="Không tìm thấy đơn nghỉ phép")
    
    if nghi_phep.nguoi_dung_id != current_user.id:
        raise HTTPException(status_code=403, detail="Không có quyền hủy đơn này")
    
    if nghi_phep.trang_thai != TrangThaiNghi.CHO_DUYET.value:
        raise HTTPException(status_code=400, detail="Chỉ có thể hủy đơn đang chờ duyệt")
    
    nghi_phep.trang_thai = TrangThaiNghi.HUY.value
    
    await db.commit()
    
    return {"message": "Hủy đơn thành công"}


@router.get("/thong-ke")
async def thong_ke_nghi_phep(
    don_vi_id: Optional[int] = None,
    nam: int = 2025,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Thống kê nghỉ phép theo đơn vị/năm"""
    is_tccb = current_user.don_vi_id == 3
    
    if not is_tccb and current_user.cap_lanh_dao > 4:
        # Chỉ xem của bản thân
        query = select(NghiPhep).where(
            NghiPhep.nguoi_dung_id == current_user.id,
            NghiPhep.trang_thai == TrangThaiNghi.DA_DUYET.value,
            NghiPhep.tu_ngay >= date(nam, 1, 1),
            NghiPhep.den_ngay <= date(nam, 12, 31)
        )
        result = await db.execute(query)
        records = result.scalars().all()
        
        tong_ngay = sum(r.so_ngay for r in records)
        return {
            "tong_ngay_nghi": tong_ngay,
            "theo_loai": {
                loai.value: sum(r.so_ngay for r in records if r.loai_nghi == loai.value)
                for loai in LoaiNghi
            }
        }
    
    # Thống kê theo đơn vị
    query = select(NghiPhep).join(
        NguoiDung, NghiPhep.nguoi_dung_id == NguoiDung.id
    ).where(
        NghiPhep.trang_thai == TrangThaiNghi.DA_DUYET.value,
        NghiPhep.tu_ngay >= date(nam, 1, 1),
        NghiPhep.den_ngay <= date(nam, 12, 31)
    )
    
    if current_user.cap_lanh_dao >= 3 and not is_tccb:
        query = query.where(NguoiDung.don_vi_id == current_user.don_vi_id)
    elif don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    # Nhóm theo người
    by_user = {}
    for r in records:
        uid = r.nguoi_dung_id
        if uid not in by_user:
            by_user[uid] = {
                "ho_ten": r.nguoi_dung.ho_ten if r.nguoi_dung else "N/A",
                "don_vi": r.nguoi_dung.don_vi.ten if r.nguoi_dung and r.nguoi_dung.don_vi else "N/A",
                "tong_ngay": 0,
                "theo_loai": {loai.value: 0 for loai in LoaiNghi}
            }
        by_user[uid]["tong_ngay"] += r.so_ngay
        by_user[uid]["theo_loai"][r.loai_nghi] += r.so_ngay
    
    return {
        "nam": nam,
        "tong_ngay_nghi": sum(u["tong_ngay"] for u in by_user.values()),
        "so_nguoi": len(by_user),
        "chi_tiet": list(by_user.values())
    }
