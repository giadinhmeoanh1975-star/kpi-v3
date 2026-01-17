from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from typing import Optional
from app.core.database import get_db
from app.core.security import get_current_user
from app.models import (
    NguoiDung, DonVi, ChucVu, SanPham, MucDo, HeSo, NgayLe
)

router = APIRouter(prefix="/danh-muc", tags=["Danh mục"])

@router.get("/don-vi")
async def get_don_vi(db: AsyncSession = Depends(get_db)):
    """Lấy danh sách đơn vị"""
    result = await db.execute(
        select(DonVi)
        .where(DonVi.trang_thai == True)
        .order_by(DonVi.thu_tu)
    )
    items = result.scalars().all()
    return [{
        "id": str(item.id),
        "ma_don_vi": item.ma_don_vi,
        "ten_don_vi": item.ten_don_vi,
        "ten_viet_tat": item.ten_viet_tat,
        "loai_don_vi": item.loai_don_vi,
        "thu_tu": item.thu_tu
    } for item in items]

@router.get("/chuc-vu")
async def get_chuc_vu(db: AsyncSession = Depends(get_db)):
    """Lấy danh sách chức vụ"""
    result = await db.execute(
        select(ChucVu)
        .where(ChucVu.trang_thai == True)
        .order_by(ChucVu.thu_tu)
    )
    items = result.scalars().all()
    return [{
        "id": str(item.id),
        "ma_chuc_vu": item.ma_chuc_vu,
        "ten_chuc_vu": item.ten_chuc_vu,
        "la_lanh_dao": item.la_lanh_dao,
        "cap_lanh_dao": item.cap_lanh_dao,
        "co_the_phe_duyet": item.co_the_phe_duyet
    } for item in items]

@router.get("/san-pham")
async def get_san_pham(db: AsyncSession = Depends(get_db)):
    """Lấy danh sách sản phẩm chuẩn"""
    result = await db.execute(
        select(SanPham)
        .where(SanPham.trang_thai == True)
        .order_by(SanPham.thu_tu)
    )
    items = result.scalars().all()
    return [{
        "id": str(item.id),
        "ma_san_pham": item.ma_san_pham,
        "ten_san_pham": item.ten_san_pham,
        "don_vi_tinh": item.don_vi_tinh,
        "thoi_gian_chuan": item.thoi_gian_chuan
    } for item in items]

@router.get("/muc-do")
async def get_muc_do(db: AsyncSession = Depends(get_db)):
    """Lấy danh sách mức độ phức tạp"""
    result = await db.execute(
        select(MucDo)
        .where(MucDo.trang_thai == True)
        .order_by(MucDo.thu_tu)
    )
    items = result.scalars().all()
    return [{
        "id": str(item.id),
        "ma_muc_do": item.ma_muc_do,
        "ten_muc_do": item.ten_muc_do,
        "mo_ta": item.mo_ta,
        "cho_phep_tu_nhap_he_so": item.cho_phep_tu_nhap_he_so
    } for item in items]

@router.get("/he-so")
async def get_he_so(
    san_pham_id: Optional[str] = None,
    muc_do_id: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    """Lấy hệ số quy đổi"""
    query = select(HeSo, SanPham.ten_san_pham, MucDo.ten_muc_do).outerjoin(
        SanPham, HeSo.san_pham_id == SanPham.id
    ).outerjoin(
        MucDo, HeSo.muc_do_id == MucDo.id
    ).where(HeSo.trang_thai == True)
    
    if san_pham_id:
        query = query.where(HeSo.san_pham_id == san_pham_id)
    if muc_do_id:
        query = query.where(HeSo.muc_do_id == muc_do_id)
    
    result = await db.execute(query)
    items = []
    for row in result.all():
        hs, sp_ten, md_ten = row
        items.append({
            "id": str(hs.id),
            "san_pham_id": str(hs.san_pham_id),
            "san_pham_ten": sp_ten,
            "muc_do_id": str(hs.muc_do_id),
            "muc_do_ten": md_ten,
            "he_so": float(hs.he_so)
        })
    return items

@router.get("/he-so/lookup")
async def lookup_he_so(
    san_pham_id: str,
    muc_do_id: str,
    db: AsyncSession = Depends(get_db)
):
    """Tra cứu hệ số theo sản phẩm và mức độ"""
    result = await db.execute(
        select(HeSo).where(
            and_(
                HeSo.san_pham_id == san_pham_id,
                HeSo.muc_do_id == muc_do_id,
                HeSo.trang_thai == True
            )
        )
    )
    hs = result.scalar_one_or_none()
    if hs:
        return {"he_so": float(hs.he_so)}
    return {"he_so": 1.0}

@router.get("/ngay-le")
async def get_ngay_le(nam: int = 2025, db: AsyncSession = Depends(get_db)):
    """Lấy danh sách ngày lễ"""
    result = await db.execute(
        select(NgayLe)
        .where(and_(NgayLe.nam == nam, NgayLe.trang_thai == True))
        .order_by(NgayLe.ngay)
    )
    items = result.scalars().all()
    return [{
        "id": str(item.id),
        "ngay": item.ngay.isoformat(),
        "ten_ngay_le": item.ten_ngay_le,
        "nam": item.nam
    } for item in items]

@router.get("/nguoi-dung")
async def get_nguoi_dung(
    don_vi_id: Optional[str] = None,
    chuc_vu_id: Optional[str] = None,
    la_lanh_dao: Optional[bool] = None,
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách người dùng (cho chọn lãnh đạo)"""
    query = select(NguoiDung, ChucVu.ten_chuc_vu, ChucVu.cap_lanh_dao, DonVi.ten_don_vi).outerjoin(
        ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
    ).outerjoin(
        DonVi, NguoiDung.don_vi_id == DonVi.id
    ).where(NguoiDung.trang_thai == True)
    
    if don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    if chuc_vu_id:
        query = query.where(NguoiDung.chuc_vu_id == chuc_vu_id)
    if la_lanh_dao is not None:
        query = query.where(ChucVu.la_lanh_dao == la_lanh_dao)
    
    result = await db.execute(query.order_by(ChucVu.thu_tu, NguoiDung.ho_ten))
    items = []
    for row in result.all():
        nd, cv_ten, cap_ld, dv_ten = row
        items.append({
            "id": str(nd.id),
            "ma_cong_chuc": nd.ma_cong_chuc,
            "ho_ten": nd.ho_ten,
            "chuc_vu_ten": cv_ten,
            "cap_lanh_dao": cap_ld,
            "don_vi_ten": dv_ten
        })
    return items

@router.get("/lanh-dao-phe-duyet")
async def get_lanh_dao_phe_duyet(
    current_user: NguoiDung = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Lấy danh sách lãnh đạo có thể phê duyệt cho người dùng hiện tại
    
    Quy tắc:
    - Công chức (cấp 5,6): chọn Phó TP/Phó ĐT (cấp 4) cùng đơn vị hoặc Trưởng phòng/ĐT (cấp 3)
    - Phó TP/Phó ĐT (cấp 4): chọn Trưởng phòng/ĐT (cấp 3) cùng đơn vị
    - Trưởng phòng/ĐT (cấp 3): chọn PCCT (cấp 2) hoặc CCT (cấp 1)
    - PCCT (cấp 2): chọn CCT (cấp 1)
    - CCT (cấp 1): không cần phê duyệt
    """
    # Lấy chức vụ người dùng hiện tại
    cv_result = await db.execute(select(ChucVu).where(ChucVu.id == current_user.chuc_vu_id))
    my_chuc_vu = cv_result.scalar_one_or_none()
    my_cap = my_chuc_vu.cap_lanh_dao if my_chuc_vu else 5
    
    items = []
    
    if my_cap >= 5:  # Công chức, Hợp đồng
        # Lấy Phó phòng/Phó đội (cấp 4) cùng đơn vị
        query = select(NguoiDung, ChucVu.ten_chuc_vu).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                NguoiDung.don_vi_id == current_user.don_vi_id,
                ChucVu.cap_lanh_dao == 4,
                NguoiDung.trang_thai == True
            )
        ).order_by(NguoiDung.ho_ten)
        
        result = await db.execute(query)
        for nd, cv_ten in result.all():
            items.append({
                "id": str(nd.id),
                "ho_ten": nd.ho_ten,
                "chuc_vu": cv_ten,
                "cap_lanh_dao": 4,
                "loai": "cap_pho"
            })
        
        # Lấy Trưởng phòng/Đội trưởng (cấp 3) cùng đơn vị
        query = select(NguoiDung, ChucVu.ten_chuc_vu).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                NguoiDung.don_vi_id == current_user.don_vi_id,
                ChucVu.cap_lanh_dao == 3,
                NguoiDung.trang_thai == True
            )
        ).order_by(NguoiDung.ho_ten)
        
        result = await db.execute(query)
        for nd, cv_ten in result.all():
            items.append({
                "id": str(nd.id),
                "ho_ten": nd.ho_ten,
                "chuc_vu": cv_ten,
                "cap_lanh_dao": 3,
                "loai": "cap_truong"
            })
    
    elif my_cap == 4:  # Phó phòng/Phó đội
        # Chọn Trưởng phòng/Đội trưởng (cấp 3) cùng đơn vị
        query = select(NguoiDung, ChucVu.ten_chuc_vu).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                NguoiDung.don_vi_id == current_user.don_vi_id,
                ChucVu.cap_lanh_dao == 3,
                NguoiDung.trang_thai == True
            )
        ).order_by(NguoiDung.ho_ten)
        
        result = await db.execute(query)
        for nd, cv_ten in result.all():
            items.append({
                "id": str(nd.id),
                "ho_ten": nd.ho_ten,
                "chuc_vu": cv_ten,
                "cap_lanh_dao": 3,
                "loai": "cap_truong"
            })
    
    elif my_cap == 3:  # Trưởng phòng/Đội trưởng
        # Chọn PCCT hoặc CCT
        query = select(NguoiDung, ChucVu.ten_chuc_vu, ChucVu.cap_lanh_dao).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                ChucVu.cap_lanh_dao.in_([1, 2]),
                NguoiDung.trang_thai == True
            )
        ).order_by(ChucVu.cap_lanh_dao, NguoiDung.ho_ten)
        
        result = await db.execute(query)
        for nd, cv_ten, cap in result.all():
            items.append({
                "id": str(nd.id),
                "ho_ten": nd.ho_ten,
                "chuc_vu": cv_ten,
                "cap_lanh_dao": cap,
                "loai": "lanh_dao_chi_cuc"
            })
    
    elif my_cap == 2:  # PCCT
        # Chọn CCT
        query = select(NguoiDung, ChucVu.ten_chuc_vu).join(
            ChucVu, NguoiDung.chuc_vu_id == ChucVu.id
        ).where(
            and_(
                ChucVu.cap_lanh_dao == 1,
                NguoiDung.trang_thai == True
            )
        )
        
        result = await db.execute(query)
        for nd, cv_ten in result.all():
            items.append({
                "id": str(nd.id),
                "ho_ten": nd.ho_ten,
                "chuc_vu": cv_ten,
                "cap_lanh_dao": 1,
                "loai": "chi_cuc_truong"
            })
    
    return items
