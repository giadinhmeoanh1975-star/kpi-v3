from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, or_
from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from datetime import datetime
from app.core.database import get_db
from app.core.security import get_current_user
from app.models import (
    KeKhai, SanPham, MucDo, NguoiDung, ChucVu, DonVi
)

router = APIRouter(prefix="/phe-duyet", tags=["Phê duyệt"])

class PheDuyetRequest(BaseModel):
    trang_thai: str  # DA_DUYET, TU_CHOI, YEU_CAU_SUA
    ly_do_tu_choi: Optional[str] = None
    chat_luong: Optional[str] = None
    tien_do: Optional[str] = None

class PheDuyetBatchRequest(BaseModel):
    ke_khai_ids: List[str]
    trang_thai: str
    ly_do_tu_choi: Optional[str] = None

async def get_user_cap(user: NguoiDung, db: AsyncSession) -> int:
    """Lấy cấp lãnh đạo của user"""
    if not user.chuc_vu_id:
        return 6
    cv_result = await db.execute(select(ChucVu).where(ChucVu.id == user.chuc_vu_id))
    chuc_vu = cv_result.scalar_one_or_none()
    return chuc_vu.cap_lanh_dao if chuc_vu else 6

@router.get("/cho-duyet")
async def get_ke_khai_cho_duyet(
    thang: int,
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách kê khai chờ duyệt
    
    Quy tắc phê duyệt:
    - Phó phòng/Phó đội (cấp 4): duyệt cho công chức (cấp 5,6) cùng đơn vị ĐÃ CHỌN MÌNH làm người duyệt
    - Trưởng phòng/Đội trưởng (cấp 3): duyệt cho cấp phó (cấp 4) cùng đơn vị
    - PCCT (cấp 2): duyệt cho TP/ĐT/CVP (cấp 3)
    - CCT (cấp 1): duyệt cho PCCT (cấp 2) và có thể duyệt cấp 3 nếu họ chọn
    """
    my_cap = await get_user_cap(current_user, db)
    
    if my_cap > 4:
        raise HTTPException(status_code=403, detail="Bạn không có quyền phê duyệt")
    
    items = []
    
    # Cấp 4 (Phó phòng/Phó đội): Duyệt cho công chức đã chọn mình
    if my_cap == 4:
        query = select(
            KeKhai, SanPham.ten_san_pham, MucDo.ten_muc_do, 
            NguoiDung.ho_ten, NguoiDung.ma_cong_chuc,
            ChucVu.ten_chuc_vu
        ).join(
            NguoiDung, KeKhai.nguoi_dung_id == NguoiDung.id
        ).outerjoin(
            SanPham, KeKhai.san_pham_id == SanPham.id
        ).outerjoin(
            MucDo, KeKhai.muc_do_id == MucDo.id
        ).outerjoin(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                KeKhai.lanh_dao_phe_duyet_id == current_user.id,  # Đã chọn mình làm người duyệt
                KeKhai.thang == thang,
                KeKhai.nam == nam,
                KeKhai.trang_thai == "CHO_DUYET"
            )
        ).order_by(NguoiDung.ho_ten, KeKhai.ngay_tao)
    
    # Cấp 3 (Trưởng phòng/Đội trưởng): Duyệt cho cấp phó cùng đơn vị
    elif my_cap == 3:
        query = select(
            KeKhai, SanPham.ten_san_pham, MucDo.ten_muc_do, 
            NguoiDung.ho_ten, NguoiDung.ma_cong_chuc,
            ChucVu.ten_chuc_vu
        ).join(
            NguoiDung, KeKhai.nguoi_dung_id == NguoiDung.id
        ).outerjoin(
            SanPham, KeKhai.san_pham_id == SanPham.id
        ).outerjoin(
            MucDo, KeKhai.muc_do_id == MucDo.id
        ).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                or_(
                    # Cấp phó cùng đơn vị
                    and_(
                        NguoiDung.don_vi_id == current_user.don_vi_id,
                        ChucVu.cap_lanh_dao == 4
                    ),
                    # Hoặc người đã chọn mình làm người duyệt
                    KeKhai.lanh_dao_phe_duyet_id == current_user.id
                ),
                KeKhai.thang == thang,
                KeKhai.nam == nam,
                KeKhai.trang_thai == "CHO_DUYET"
            )
        ).order_by(NguoiDung.ho_ten, KeKhai.ngay_tao)
    
    # Cấp 2 (PCCT): Duyệt cho cấp 3 (TP, ĐT, CVP)
    elif my_cap == 2:
        query = select(
            KeKhai, SanPham.ten_san_pham, MucDo.ten_muc_do, 
            NguoiDung.ho_ten, NguoiDung.ma_cong_chuc,
            ChucVu.ten_chuc_vu
        ).join(
            NguoiDung, KeKhai.nguoi_dung_id == NguoiDung.id
        ).outerjoin(
            SanPham, KeKhai.san_pham_id == SanPham.id
        ).outerjoin(
            MucDo, KeKhai.muc_do_id == MucDo.id
        ).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                or_(
                    ChucVu.cap_lanh_dao == 3,  # Cấp 3
                    KeKhai.lanh_dao_phe_duyet_id == current_user.id  # Hoặc đã chọn mình
                ),
                KeKhai.thang == thang,
                KeKhai.nam == nam,
                KeKhai.trang_thai == "CHO_DUYET"
            )
        ).order_by(NguoiDung.ho_ten, KeKhai.ngay_tao)
    
    # Cấp 1 (CCT): Duyệt cho cấp 2 (PCCT) và cấp 3 nếu họ chọn
    elif my_cap == 1:
        query = select(
            KeKhai, SanPham.ten_san_pham, MucDo.ten_muc_do, 
            NguoiDung.ho_ten, NguoiDung.ma_cong_chuc,
            ChucVu.ten_chuc_vu
        ).join(
            NguoiDung, KeKhai.nguoi_dung_id == NguoiDung.id
        ).outerjoin(
            SanPham, KeKhai.san_pham_id == SanPham.id
        ).outerjoin(
            MucDo, KeKhai.muc_do_id == MucDo.id
        ).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                or_(
                    ChucVu.cap_lanh_dao == 2,  # PCCT
                    KeKhai.lanh_dao_phe_duyet_id == current_user.id  # Hoặc đã chọn mình
                ),
                KeKhai.thang == thang,
                KeKhai.nam == nam,
                KeKhai.trang_thai == "CHO_DUYET"
            )
        ).order_by(NguoiDung.ho_ten, KeKhai.ngay_tao)
    
    else:
        return []
    
    result = await db.execute(query)
    for row in result.all():
        kk, sp_ten, md_ten, nd_ten, nd_ma, cv_ten = row
        items.append({
            "id": str(kk.id),
            "nguoi_dung_id": str(kk.nguoi_dung_id),
            "nguoi_dung_ten": nd_ten,
            "nguoi_dung_ma": nd_ma,
            "chuc_vu": cv_ten,
            "san_pham_ten": sp_ten,
            "so_luong": kk.so_luong,
            "ket_qua": kk.ket_qua,
            "muc_do_ten": md_ten,
            "he_so": float(kk.he_so) if kk.he_so else None,
            "he_so_tu_nhap": float(kk.he_so_tu_nhap) if kk.he_so_tu_nhap else None,
            "tien_do": kk.tien_do,
            "chat_luong": kk.chat_luong,
            "ghi_chu": kk.ghi_chu,
            "ngay_tao": kk.ngay_tao.isoformat() if kk.ngay_tao else None
        })
    
    return items

@router.get("/da-duyet")
async def get_ke_khai_da_duyet(
    thang: int,
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách kê khai đã duyệt bởi mình"""
    query = select(
        KeKhai, SanPham.ten_san_pham, MucDo.ten_muc_do, 
        NguoiDung.ho_ten, NguoiDung.ma_cong_chuc
    ).join(
        NguoiDung, KeKhai.nguoi_dung_id == NguoiDung.id
    ).outerjoin(
        SanPham, KeKhai.san_pham_id == SanPham.id
    ).outerjoin(
        MucDo, KeKhai.muc_do_id == MucDo.id
    ).where(
        and_(
            KeKhai.nguoi_duyet_id == current_user.id,
            KeKhai.thang == thang,
            KeKhai.nam == nam,
            KeKhai.trang_thai.in_(["DA_DUYET", "TU_CHOI", "YEU_CAU_SUA"])
        )
    ).order_by(KeKhai.ngay_duyet.desc())
    
    result = await db.execute(query)
    items = []
    for row in result.all():
        kk, sp_ten, md_ten, nd_ten, nd_ma = row
        items.append({
            "id": str(kk.id),
            "nguoi_dung_ten": nd_ten,
            "nguoi_dung_ma": nd_ma,
            "san_pham_ten": sp_ten,
            "so_luong": kk.so_luong,
            "muc_do_ten": md_ten,
            "he_so": float(kk.he_so) if kk.he_so else None,
            "tien_do": kk.tien_do,
            "chat_luong": kk.chat_luong,
            "trang_thai": kk.trang_thai,
            "ly_do_tu_choi": kk.ly_do_tu_choi,
            "ngay_duyet": kk.ngay_duyet.isoformat() if kk.ngay_duyet else None
        })
    
    return items

@router.post("/{id}")
async def phe_duyet_ke_khai(
    id: str,
    data: PheDuyetRequest,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Phê duyệt một kê khai"""
    my_cap = await get_user_cap(current_user, db)
    
    if my_cap > 4:
        raise HTTPException(status_code=403, detail="Bạn không có quyền phê duyệt")
    
    # Lấy kê khai
    result = await db.execute(select(KeKhai).where(KeKhai.id == id))
    ke_khai = result.scalar_one_or_none()
    
    if not ke_khai:
        raise HTTPException(status_code=404, detail="Không tìm thấy kê khai")
    
    if ke_khai.trang_thai != "CHO_DUYET":
        raise HTTPException(status_code=400, detail="Kê khai không ở trạng thái chờ duyệt")
    
    # Kiểm tra quyền duyệt
    can_approve = False
    
    # Nếu đã được chọn làm người duyệt
    if ke_khai.lanh_dao_phe_duyet_id == current_user.id:
        can_approve = True
    else:
        # Lấy thông tin người kê khai
        nd_result = await db.execute(
            select(NguoiDung, ChucVu).join(
                ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
            ).where(NguoiDung.id == ke_khai.nguoi_dung_id)
        )
        row = nd_result.first()
        if row:
            nguoi_ke_khai, cv_ke_khai = row
            target_cap = cv_ke_khai.cap_lanh_dao
            
            # Cấp 3 duyệt cho cấp 4 cùng đơn vị
            if my_cap == 3 and target_cap == 4 and nguoi_ke_khai.don_vi_id == current_user.don_vi_id:
                can_approve = True
            # Cấp 2 duyệt cho cấp 3
            elif my_cap == 2 and target_cap == 3:
                can_approve = True
            # Cấp 1 duyệt cho cấp 2
            elif my_cap == 1 and target_cap == 2:
                can_approve = True
    
    if not can_approve:
        raise HTTPException(status_code=403, detail="Bạn không có quyền duyệt kê khai này")
    
    # Cập nhật trạng thái
    if data.trang_thai not in ["DA_DUYET", "TU_CHOI", "YEU_CAU_SUA"]:
        raise HTTPException(status_code=400, detail="Trạng thái không hợp lệ")
    
    ke_khai.trang_thai = data.trang_thai
    ke_khai.nguoi_duyet_id = current_user.id
    ke_khai.ngay_duyet = datetime.utcnow()
    
    if data.trang_thai in ["TU_CHOI", "YEU_CAU_SUA"]:
        ke_khai.ly_do_tu_choi = data.ly_do_tu_choi
    
    if data.chat_luong:
        ke_khai.chat_luong = data.chat_luong
    if data.tien_do:
        ke_khai.tien_do = data.tien_do
    
    await db.commit()
    
    return {"message": "Phê duyệt thành công"}

@router.post("/batch")
async def phe_duyet_batch(
    data: PheDuyetBatchRequest,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Phê duyệt nhiều kê khai cùng lúc"""
    my_cap = await get_user_cap(current_user, db)
    
    if my_cap > 4:
        raise HTTPException(status_code=403, detail="Bạn không có quyền phê duyệt")
    
    if data.trang_thai not in ["DA_DUYET", "TU_CHOI", "YEU_CAU_SUA"]:
        raise HTTPException(status_code=400, detail="Trạng thái không hợp lệ")
    
    success_count = 0
    for kk_id in data.ke_khai_ids:
        result = await db.execute(select(KeKhai).where(KeKhai.id == kk_id))
        ke_khai = result.scalar_one_or_none()
        
        if ke_khai and ke_khai.trang_thai == "CHO_DUYET":
            # Kiểm tra quyền (đơn giản hóa: chỉ duyệt những người đã chọn mình)
            if ke_khai.lanh_dao_phe_duyet_id == current_user.id:
                ke_khai.trang_thai = data.trang_thai
                ke_khai.nguoi_duyet_id = current_user.id
                ke_khai.ngay_duyet = datetime.utcnow()
                if data.trang_thai in ["TU_CHOI", "YEU_CAU_SUA"]:
                    ke_khai.ly_do_tu_choi = data.ly_do_tu_choi
                success_count += 1
    
    await db.commit()
    
    return {"message": f"Đã phê duyệt {success_count}/{len(data.ke_khai_ids)} kê khai"}

@router.get("/thong-ke")
async def thong_ke_phe_duyet(
    thang: int,
    nam: int,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Thống kê phê duyệt trong tháng"""
    my_cap = await get_user_cap(current_user, db)
    
    if my_cap > 4:
        return {"message": "Bạn không có quyền phê duyệt", "cho_duyet": 0, "da_duyet": 0}
    
    # Đếm chờ duyệt (đã chọn mình làm người duyệt)
    cho_duyet_result = await db.execute(
        select(KeKhai).where(
            and_(
                KeKhai.lanh_dao_phe_duyet_id == current_user.id,
                KeKhai.thang == thang,
                KeKhai.nam == nam,
                KeKhai.trang_thai == "CHO_DUYET"
            )
        )
    )
    cho_duyet = len(cho_duyet_result.scalars().all())
    
    # Đếm đã duyệt
    da_duyet_result = await db.execute(
        select(KeKhai).where(
            and_(
                KeKhai.nguoi_duyet_id == current_user.id,
                KeKhai.thang == thang,
                KeKhai.nam == nam,
                KeKhai.trang_thai.in_(["DA_DUYET", "TU_CHOI", "YEU_CAU_SUA"])
            )
        )
    )
    da_duyet = len(da_duyet_result.scalars().all())
    
    return {
        "thang": thang,
        "nam": nam,
        "cho_duyet": cho_duyet,
        "da_duyet": da_duyet,
        "cap_lanh_dao": my_cap
    }
