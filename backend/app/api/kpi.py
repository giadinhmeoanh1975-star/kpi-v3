"""
API KPI - Tính toán và báo cáo KPI hàng tháng
"""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_, or_
from datetime import date
from typing import Optional
from pydantic import BaseModel

from ..core.database import get_db
from ..core.security import get_current_user
from ..models import (
    NguoiDung, KeKhai, TieuChiChung, DiemLanhDao, 
    KPIThang, NghiPhep, NhiemVu, DonVi
)

router = APIRouter(prefix="/kpi", tags=["KPI"])

class XepLoai(str):
    XUAT_SAC = "Xuất sắc"
    TOT = "Tốt"
    HOAN_THANH = "Hoàn thành"
    KHONG_HOAN_THANH = "Không hoàn thành"


def tinh_xep_loai(diem_tong: float, he_so_ngay_nghi: float = 1.0) -> str:
    """Tính xếp loại dựa trên điểm tổng và hệ số ngày nghỉ"""
    diem_cuoi = diem_tong * he_so_ngay_nghi
    
    if diem_cuoi >= 90:
        return XepLoai.XUAT_SAC
    elif diem_cuoi >= 70:
        return XepLoai.TOT
    elif diem_cuoi >= 50:
        return XepLoai.HOAN_THANH
    else:
        return XepLoai.KHONG_HOAN_THANH


@router.get("/cua-toi")
async def get_my_kpi(
    nam: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy KPI của bản thân"""
    query = select(KPIThang).where(KPIThang.nguoi_dung_id == current_user.id)
    
    if nam:
        query = query.where(KPIThang.nam == nam)
    
    query = query.order_by(KPIThang.nam.desc(), KPIThang.thang.desc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "thang": r.thang,
        "nam": r.nam,
        "diem_san_pham": r.diem_san_pham,
        "diem_tieu_chi_chung": r.diem_tieu_chi_chung,
        "diem_lanh_dao": r.diem_lanh_dao,
        "diem_nhiem_vu": r.diem_nhiem_vu,
        "diem_tong": r.diem_tong,
        "so_ngay_nghi": r.so_ngay_nghi,
        "he_so_ngay_nghi": r.he_so_ngay_nghi,
        "diem_cuoi": r.diem_cuoi,
        "xep_loai": r.xep_loai,
        "ghi_chu": r.ghi_chu,
        "ngay_tinh": r.ngay_tinh.isoformat() if r.ngay_tinh else None
    } for r in records]


@router.get("/don-vi")
async def get_kpi_don_vi(
    don_vi_id: Optional[int] = None,
    thang: Optional[int] = None,
    nam: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Lấy KPI theo đơn vị - chỉ lãnh đạo hoặc TCCB"""
    is_tccb = current_user.don_vi_id == 3
    
    if not is_tccb and current_user.cap_lanh_dao > 4:
        raise HTTPException(status_code=403, detail="Không có quyền xem KPI đơn vị")
    
    query = select(KPIThang).join(NguoiDung, KPIThang.nguoi_dung_id == NguoiDung.id)
    
    if current_user.cap_lanh_dao >= 3 and not is_tccb:
        query = query.where(NguoiDung.don_vi_id == current_user.don_vi_id)
    elif don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    
    if thang:
        query = query.where(KPIThang.thang == thang)
    if nam:
        query = query.where(KPIThang.nam == nam)
    
    query = query.order_by(NguoiDung.don_vi_id, KPIThang.diem_tong.desc())
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "id": r.id,
        "nguoi_dung_id": r.nguoi_dung_id,
        "ho_ten": r.nguoi_dung.ho_ten if r.nguoi_dung else None,
        "don_vi_ten": r.nguoi_dung.don_vi.ten if r.nguoi_dung and r.nguoi_dung.don_vi else None,
        "chuc_vu_ten": r.nguoi_dung.chuc_vu.ten if r.nguoi_dung and r.nguoi_dung.chuc_vu else None,
        "thang": r.thang,
        "nam": r.nam,
        "diem_san_pham": r.diem_san_pham,
        "diem_tieu_chi_chung": r.diem_tieu_chi_chung,
        "diem_lanh_dao": r.diem_lanh_dao,
        "diem_nhiem_vu": r.diem_nhiem_vu,
        "diem_tong": r.diem_tong,
        "diem_cuoi": r.diem_cuoi,
        "xep_loai": r.xep_loai
    } for r in records]


@router.post("/tinh/{thang}/{nam}")
async def tinh_kpi_thang(
    thang: int,
    nam: int,
    don_vi_id: Optional[int] = None,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Tính KPI cho tháng - chỉ TCCB hoặc admin"""
    is_tccb = current_user.don_vi_id == 3
    is_admin = current_user.tai_khoan == "admin"
    
    if not is_tccb and not is_admin and current_user.cap_lanh_dao > 2:
        raise HTTPException(status_code=403, detail="Không có quyền tính KPI")
    
    if thang < 1 or thang > 12:
        raise HTTPException(status_code=400, detail="Tháng không hợp lệ")
    
    # Lấy danh sách người dùng cần tính
    query = select(NguoiDung).where(NguoiDung.trang_thai == True)
    if don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    
    result = await db.execute(query)
    users = result.scalars().all()
    
    results = []
    for user in users:
        try:
            kpi_data = await _tinh_kpi_nguoi_dung(db, user.id, thang, nam)
            results.append({
                "nguoi_dung_id": user.id,
                "ho_ten": user.ho_ten,
                "status": "success",
                **kpi_data
            })
        except Exception as e:
            results.append({
                "nguoi_dung_id": user.id,
                "ho_ten": user.ho_ten,
                "status": "error",
                "error": str(e)
            })
    
    await db.commit()
    
    success_count = len([r for r in results if r["status"] == "success"])
    return {
        "message": f"Đã tính KPI cho {success_count}/{len(users)} người",
        "thang": thang,
        "nam": nam,
        "chi_tiet": results
    }


async def _tinh_kpi_nguoi_dung(db: AsyncSession, nguoi_dung_id: int, thang: int, nam: int) -> dict:
    """Tính KPI cho một người dùng"""
    
    # 1. Điểm sản phẩm (70%)
    ke_khai_query = select(KeKhai).where(
        KeKhai.nguoi_dung_id == nguoi_dung_id,
        KeKhai.thang == thang,
        KeKhai.nam == nam,
        KeKhai.trang_thai == "DA_DUYET"
    )
    result = await db.execute(ke_khai_query)
    ke_khais = result.scalars().all()
    
    tong_he_so_quy_doi = sum(kk.he_so_quy_doi or 0 for kk in ke_khais)
    # Điểm sản phẩm = (tổng hệ số quy đổi / 1.0) * 70, tối đa 70 điểm
    diem_san_pham = min(tong_he_so_quy_doi * 70, 70)
    
    # 2. Điểm tiêu chí chung (30%)
    tieu_chi_query = select(TieuChiChung).where(
        TieuChiChung.nguoi_duoc_cham_id == nguoi_dung_id,
        TieuChiChung.thang == thang,
        TieuChiChung.nam == nam
    )
    result = await db.execute(tieu_chi_query)
    tieu_chi = result.scalar_one_or_none()
    diem_tieu_chi_chung = tieu_chi.tong_diem if tieu_chi else 30  # Mặc định 30 nếu chưa chấm
    
    # 3. Điểm lãnh đạo (bonus/penalty)
    lanh_dao_query = select(DiemLanhDao).where(
        DiemLanhDao.nguoi_duoc_cham_id == nguoi_dung_id,
        DiemLanhDao.thang == thang,
        DiemLanhDao.nam == nam
    )
    result = await db.execute(lanh_dao_query)
    diem_lanh_dao_records = result.scalars().all()
    
    diem_lanh_dao = 0
    for dl in diem_lanh_dao_records:
        if dl.xep_loai == "D":  # Xuất sắc
            diem_lanh_dao += 5
        elif dl.xep_loai == "Đ":  # Đạt
            diem_lanh_dao += 0
        elif dl.xep_loai == "E":  # Không đạt
            diem_lanh_dao -= 5
    
    # 4. Điểm nhiệm vụ được giao
    nhiem_vu_query = select(NhiemVu).where(
        NhiemVu.nguoi_thuc_hien_id == nguoi_dung_id,
        NhiemVu.thang == thang,
        NhiemVu.nam == nam,
        NhiemVu.trang_thai == "HOAN_THANH"
    )
    result = await db.execute(nhiem_vu_query)
    nhiem_vus = result.scalars().all()
    
    diem_nhiem_vu = 0
    for nv in nhiem_vus:
        if nv.danh_gia_lanh_dao:
            if nv.danh_gia_lanh_dao == "TOT":
                diem_nhiem_vu += 2
            elif nv.danh_gia_lanh_dao == "DAT":
                diem_nhiem_vu += 1
            elif nv.danh_gia_lanh_dao == "KHONG_DAT":
                diem_nhiem_vu -= 2
    
    # 5. Tính số ngày nghỉ và hệ số
    nghi_phep_query = select(NghiPhep).where(
        NghiPhep.nguoi_dung_id == nguoi_dung_id,
        NghiPhep.trang_thai == "DA_DUYET",
        or_(
            and_(
                func.extract('month', NghiPhep.tu_ngay) == thang,
                func.extract('year', NghiPhep.tu_ngay) == nam
            ),
            and_(
                func.extract('month', NghiPhep.den_ngay) == thang,
                func.extract('year', NghiPhep.den_ngay) == nam
            )
        )
    )
    result = await db.execute(nghi_phep_query)
    nghi_pheps = result.scalars().all()
    
    so_ngay_nghi = sum(np.so_ngay for np in nghi_pheps)
    
    # Hệ số ngày nghỉ: nghỉ > 10 ngày thì hệ số giảm
    if so_ngay_nghi <= 2:
        he_so_ngay_nghi = 1.0
    elif so_ngay_nghi <= 5:
        he_so_ngay_nghi = 0.95
    elif so_ngay_nghi <= 10:
        he_so_ngay_nghi = 0.9
    else:
        he_so_ngay_nghi = 0.8
    
    # 6. Tính điểm tổng
    diem_tong = diem_san_pham + diem_tieu_chi_chung + diem_lanh_dao + diem_nhiem_vu
    diem_cuoi = diem_tong * he_so_ngay_nghi
    xep_loai = tinh_xep_loai(diem_tong, he_so_ngay_nghi)
    
    # 7. Lưu hoặc cập nhật KPI
    existing_query = select(KPIThang).where(
        KPIThang.nguoi_dung_id == nguoi_dung_id,
        KPIThang.thang == thang,
        KPIThang.nam == nam
    )
    result = await db.execute(existing_query)
    existing = result.scalar_one_or_none()
    
    if existing:
        existing.diem_san_pham = diem_san_pham
        existing.diem_tieu_chi_chung = diem_tieu_chi_chung
        existing.diem_lanh_dao = diem_lanh_dao
        existing.diem_nhiem_vu = diem_nhiem_vu
        existing.diem_tong = diem_tong
        existing.so_ngay_nghi = so_ngay_nghi
        existing.he_so_ngay_nghi = he_so_ngay_nghi
        existing.diem_cuoi = diem_cuoi
        existing.xep_loai = xep_loai
        kpi = existing
    else:
        kpi = KPIThang(
            nguoi_dung_id=nguoi_dung_id,
            thang=thang,
            nam=nam,
            diem_san_pham=diem_san_pham,
            diem_tieu_chi_chung=diem_tieu_chi_chung,
            diem_lanh_dao=diem_lanh_dao,
            diem_nhiem_vu=diem_nhiem_vu,
            diem_tong=diem_tong,
            so_ngay_nghi=so_ngay_nghi,
            he_so_ngay_nghi=he_so_ngay_nghi,
            diem_cuoi=diem_cuoi,
            xep_loai=xep_loai
        )
        db.add(kpi)
    
    return {
        "diem_san_pham": round(diem_san_pham, 2),
        "diem_tieu_chi_chung": round(diem_tieu_chi_chung, 2),
        "diem_lanh_dao": diem_lanh_dao,
        "diem_nhiem_vu": diem_nhiem_vu,
        "diem_tong": round(diem_tong, 2),
        "so_ngay_nghi": so_ngay_nghi,
        "he_so_ngay_nghi": he_so_ngay_nghi,
        "diem_cuoi": round(diem_cuoi, 2),
        "xep_loai": xep_loai
    }


@router.get("/thong-ke")
async def thong_ke_kpi(
    thang: Optional[int] = None,
    nam: int = 2025,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Thống kê KPI theo xếp loại"""
    is_tccb = current_user.don_vi_id == 3
    
    query = select(KPIThang).join(NguoiDung, KPIThang.nguoi_dung_id == NguoiDung.id)
    
    if thang:
        query = query.where(KPIThang.thang == thang)
    query = query.where(KPIThang.nam == nam)
    
    if current_user.cap_lanh_dao >= 3 and not is_tccb:
        query = query.where(NguoiDung.don_vi_id == current_user.don_vi_id)
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    thong_ke = {
        XepLoai.XUAT_SAC: 0,
        XepLoai.TOT: 0,
        XepLoai.HOAN_THANH: 0,
        XepLoai.KHONG_HOAN_THANH: 0
    }
    
    tong_diem = 0
    for r in records:
        thong_ke[r.xep_loai] = thong_ke.get(r.xep_loai, 0) + 1
        tong_diem += r.diem_cuoi or 0
    
    return {
        "thang": thang,
        "nam": nam,
        "tong_so": len(records),
        "diem_trung_binh": round(tong_diem / len(records), 2) if records else 0,
        "theo_xep_loai": thong_ke,
        "ty_le": {
            k: round(v / len(records) * 100, 1) if records else 0 
            for k, v in thong_ke.items()
        }
    }


@router.get("/xep-hang")
async def xep_hang_kpi(
    thang: int,
    nam: int,
    don_vi_id: Optional[int] = None,
    limit: int = 20,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Xếp hạng KPI cao nhất"""
    is_tccb = current_user.don_vi_id == 3
    
    query = select(KPIThang).join(
        NguoiDung, KPIThang.nguoi_dung_id == NguoiDung.id
    ).where(
        KPIThang.thang == thang,
        KPIThang.nam == nam
    )
    
    if current_user.cap_lanh_dao >= 3 and not is_tccb:
        query = query.where(NguoiDung.don_vi_id == current_user.don_vi_id)
    elif don_vi_id:
        query = query.where(NguoiDung.don_vi_id == don_vi_id)
    
    query = query.order_by(KPIThang.diem_cuoi.desc()).limit(limit)
    
    result = await db.execute(query)
    records = result.scalars().all()
    
    return [{
        "hang": i + 1,
        "nguoi_dung_id": r.nguoi_dung_id,
        "ho_ten": r.nguoi_dung.ho_ten if r.nguoi_dung else None,
        "don_vi_ten": r.nguoi_dung.don_vi.ten if r.nguoi_dung and r.nguoi_dung.don_vi else None,
        "chuc_vu_ten": r.nguoi_dung.chuc_vu.ten if r.nguoi_dung and r.nguoi_dung.chuc_vu else None,
        "diem_cuoi": r.diem_cuoi,
        "xep_loai": r.xep_loai
    } for i, r in enumerate(records)]


@router.get("/bao-cao-don-vi")
async def bao_cao_kpi_don_vi(
    thang: int,
    nam: int,
    db: AsyncSession = Depends(get_db),
    current_user: NguoiDung = Depends(get_current_user)
):
    """Báo cáo KPI theo từng đơn vị"""
    is_tccb = current_user.don_vi_id == 3
    is_admin = current_user.tai_khoan == "admin"
    
    if not is_tccb and not is_admin and current_user.cap_lanh_dao > 2:
        raise HTTPException(status_code=403, detail="Không có quyền xem báo cáo này")
    
    # Lấy tất cả đơn vị
    don_vi_result = await db.execute(select(DonVi).where(DonVi.trang_thai == True))
    don_vis = don_vi_result.scalars().all()
    
    bao_cao = []
    for dv in don_vis:
        query = select(KPIThang).join(
            NguoiDung, KPIThang.nguoi_dung_id == NguoiDung.id
        ).where(
            NguoiDung.don_vi_id == dv.id,
            KPIThang.thang == thang,
            KPIThang.nam == nam
        )
        
        result = await db.execute(query)
        records = result.scalars().all()
        
        if not records:
            continue
        
        thong_ke = {
            XepLoai.XUAT_SAC: 0,
            XepLoai.TOT: 0,
            XepLoai.HOAN_THANH: 0,
            XepLoai.KHONG_HOAN_THANH: 0
        }
        
        tong_diem = 0
        for r in records:
            thong_ke[r.xep_loai] = thong_ke.get(r.xep_loai, 0) + 1
            tong_diem += r.diem_cuoi or 0
        
        bao_cao.append({
            "don_vi_id": dv.id,
            "don_vi_ten": dv.ten,
            "so_nguoi": len(records),
            "diem_trung_binh": round(tong_diem / len(records), 2),
            "theo_xep_loai": thong_ke
        })
    
    # Sắp xếp theo điểm trung bình giảm dần
    bao_cao.sort(key=lambda x: x["diem_trung_binh"], reverse=True)
    
    return {
        "thang": thang,
        "nam": nam,
        "don_vi": bao_cao
    }
