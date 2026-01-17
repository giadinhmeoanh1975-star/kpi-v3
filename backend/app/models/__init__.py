from sqlalchemy import Column, String, Integer, Boolean, DateTime, Date, ForeignKey, Text, DECIMAL, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid

from app.core.database import Base

class DonVi(Base):
    __tablename__ = "dm_don_vi"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ma_don_vi = Column(String(20), unique=True, nullable=False)
    ten_don_vi = Column(String(200), nullable=False)
    ten_viet_tat = Column(String(50))
    loai_don_vi = Column(String(30))
    thu_tu = Column(Integer, default=0)
    trang_thai = Column(Boolean, default=True)
    ngay_tao = Column(DateTime, default=func.now())

class ChucVu(Base):
    __tablename__ = "dm_chuc_vu"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ma_chuc_vu = Column(String(10), unique=True, nullable=False)
    ten_chuc_vu = Column(String(100), nullable=False)
    la_lanh_dao = Column(Boolean, default=False)
    cap_lanh_dao = Column(Integer, default=0)
    co_the_phe_duyet = Column(Boolean, default=False)
    co_the_ke_khai = Column(Boolean, default=True)
    thu_tu = Column(Integer, default=0)
    trang_thai = Column(Boolean, default=True)

class SanPham(Base):
    __tablename__ = "dm_san_pham"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ma_san_pham = Column(String(20), unique=True, nullable=False)
    ten_san_pham = Column(String(300), nullable=False)
    don_vi_tinh = Column(String(50))
    thoi_gian_chuan = Column(Integer, default=60)
    thu_tu = Column(Integer, default=0)
    trang_thai = Column(Boolean, default=True)

class MucDo(Base):
    __tablename__ = "dm_muc_do"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ma_muc_do = Column(String(10), unique=True, nullable=False)
    ten_muc_do = Column(String(50), nullable=False)
    mo_ta = Column(Text)
    cho_phep_tu_nhap_he_so = Column(Boolean, default=False)
    thu_tu = Column(Integer, default=0)
    trang_thai = Column(Boolean, default=True)

class HeSo(Base):
    __tablename__ = "dm_he_so"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    san_pham_id = Column(UUID(as_uuid=True), ForeignKey("dm_san_pham.id"))
    muc_do_id = Column(UUID(as_uuid=True), ForeignKey("dm_muc_do.id"))
    he_so = Column(DECIMAL(10, 2), nullable=False)
    trang_thai = Column(Boolean, default=True)

class NgayLe(Base):
    __tablename__ = "dm_ngay_le"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ngay = Column(Date, nullable=False, unique=True)
    ten_ngay_le = Column(String(200), nullable=False)
    nam = Column(Integer, nullable=False)
    trang_thai = Column(Boolean, default=True)

class NguoiDung(Base):
    __tablename__ = "nguoi_dung"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ma_cong_chuc = Column(String(30), unique=True, nullable=False)
    mat_khau = Column(String(255), nullable=False)
    ho_ten = Column(String(200), nullable=False)
    nam_sinh = Column(String(20))
    don_vi_id = Column(UUID(as_uuid=True), ForeignKey("dm_don_vi.id"))
    chuc_vu_id = Column(UUID(as_uuid=True), ForeignKey("dm_chuc_vu.id"))
    email = Column(String(100))
    so_dien_thoai = Column(String(20))
    la_admin = Column(Boolean, default=False)
    la_tccb = Column(Boolean, default=False)
    lanh_dao_truc_tiep_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    trang_thai = Column(Boolean, default=True)
    ngay_tao = Column(DateTime, default=func.now())
    ngay_cap_nhat = Column(DateTime, default=func.now(), onupdate=func.now())
    
    don_vi = relationship("DonVi", foreign_keys=[don_vi_id])
    chuc_vu = relationship("ChucVu", foreign_keys=[chuc_vu_id])

class KeKhai(Base):
    __tablename__ = "ke_khai"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_dung_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    thang = Column(Integer, nullable=False)
    nam = Column(Integer, nullable=False)
    san_pham_id = Column(UUID(as_uuid=True), ForeignKey("dm_san_pham.id"))
    so_luong = Column(Integer, default=1)
    ket_qua = Column(Text)
    muc_do_id = Column(UUID(as_uuid=True), ForeignKey("dm_muc_do.id"))
    he_so = Column(DECIMAL(10, 2))
    he_so_tu_nhap = Column(DECIMAL(10, 2))
    tien_do = Column(String(20), default='DAT')
    chat_luong = Column(String(20), default='DAT')
    so_lan_khong_dat_tien_do = Column(Integer, default=0)
    so_lan_khong_dat_chat_luong = Column(Integer, default=0)
    lanh_dao_giao_viec_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    lanh_dao_phe_duyet_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    trang_thai = Column(String(30), default='NHAP')
    nguoi_duyet_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    ngay_duyet = Column(DateTime)
    ly_do_tu_choi = Column(Text)
    ghi_chu = Column(Text)
    ngay_tao = Column(DateTime, default=func.now())
    ngay_cap_nhat = Column(DateTime, default=func.now(), onupdate=func.now())

class NhiemVu(Base):
    __tablename__ = "nhiem_vu"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_giao_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    nguoi_nhan_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    thang = Column(Integer, nullable=False)
    nam = Column(Integer, nullable=False)
    noi_dung = Column(Text, nullable=False)
    san_pham_id = Column(UUID(as_uuid=True), ForeignKey("dm_san_pham.id"))
    muc_do_id = Column(UUID(as_uuid=True), ForeignKey("dm_muc_do.id"))
    han_hoan_thanh = Column(Date)
    ket_qua_mong_doi = Column(Text)
    tu_danh_gia_hoan_thanh = Column(String(20))
    tu_danh_gia_tien_do = Column(String(20))
    tu_danh_gia_chat_luong = Column(String(20))
    tu_danh_gia_ghi_chu = Column(Text)
    danh_gia_hoan_thanh = Column(String(20))
    danh_gia_tien_do = Column(String(20))
    danh_gia_chat_luong = Column(String(20))
    so_lan_khong_dat_tien_do = Column(Integer, default=0)
    so_lan_khong_dat_chat_luong = Column(Integer, default=0)
    danh_gia_ghi_chu = Column(Text)
    trang_thai = Column(String(30), default='MOI_GIAO')
    ngay_tao = Column(DateTime, default=func.now())
    ngay_cap_nhat = Column(DateTime, default=func.now(), onupdate=func.now())

class TieuChiChung(Base):
    __tablename__ = "tieu_chi_chung"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_dung_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    thang = Column(Integer, nullable=False)
    nam = Column(Integer, nullable=False)
    tc_1a_vi_pham = Column(Boolean, default=False)
    tc_1a_ten_vb = Column(String(500))
    tc_1a_diem = Column(DECIMAL(4, 2), default=5)
    tc_1b_vi_pham = Column(Boolean, default=False)
    tc_1b_ten_vb = Column(String(500))
    tc_1b_diem = Column(DECIMAL(4, 2), default=5)
    tc_2a_dap_ung = Column(Boolean, default=True)
    tc_2a_diem = Column(DECIMAL(4, 2), default=2.5)
    tc_2b_dap_ung = Column(Boolean, default=True)
    tc_2b_diem = Column(DECIMAL(4, 2), default=2.5)
    tc_2c_dap_ung = Column(Boolean, default=True)
    tc_2c_diem = Column(DECIMAL(4, 2), default=2.5)
    tc_2d_dap_ung = Column(Boolean, default=True)
    tc_2d_diem = Column(DECIMAL(4, 2), default=2.5)
    tc_3_dap_ung = Column(Boolean, default=True)
    tc_3_diem = Column(DECIMAL(4, 2), default=5)
    tong_diem_tc = Column(DECIMAL(5, 2), default=30)
    nguoi_danh_gia_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    ghi_chu = Column(Text)
    ngay_tao = Column(DateTime, default=func.now())
    ngay_cap_nhat = Column(DateTime, default=func.now(), onupdate=func.now())

class DiemLanhDao(Base):
    __tablename__ = "diem_lanh_dao"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_dung_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    thang = Column(Integer, nullable=False)
    nam = Column(Integer, nullable=False)
    diem_d = Column(DECIMAL(5, 2))
    diem_d_ghi_chu = Column(Text)
    diem_dd = Column(DECIMAL(5, 2))
    diem_dd_ghi_chu = Column(Text)
    diem_e = Column(DECIMAL(5, 2))
    diem_e_ghi_chu = Column(Text)
    nguoi_danh_gia_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    ngay_tao = Column(DateTime, default=func.now())
    ngay_cap_nhat = Column(DateTime, default=func.now(), onupdate=func.now())

class NghiPhep(Base):
    __tablename__ = "nghi_phep"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_dung_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    tu_ngay = Column(Date, nullable=False)
    den_ngay = Column(Date, nullable=False)
    so_ngay = Column(DECIMAL(4, 1), nullable=False)
    loai_nghi = Column(String(50), default='PHEP_NAM')
    ly_do = Column(Text)
    trang_thai = Column(String(20), default='CHO_DUYET')
    nguoi_duyet_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    ngay_duyet = Column(DateTime)
    ly_do_tu_choi = Column(Text)
    ngay_tao = Column(DateTime, default=func.now())

class TruongHopDacBiet(Base):
    __tablename__ = "truong_hop_dac_biet"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_dung_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    thang = Column(Integer, nullable=False)
    nam = Column(Integer, nullable=False)
    loai = Column(String(50), nullable=False)
    khong_danh_gia = Column(Boolean, default=False)
    tru_30_diem = Column(Boolean, default=False)
    so_thang_tru = Column(Integer, default=0)
    ghi_chu = Column(Text)
    nguoi_tao_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    ngay_tao = Column(DateTime, default=func.now())

class KpiThang(Base):
    __tablename__ = "kpi_thang"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_dung_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"), nullable=False)
    thang = Column(Integer, nullable=False)
    nam = Column(Integer, nullable=False)
    la_lanh_dao = Column(Boolean, default=False)
    diem_a = Column(DECIMAL(8, 4), default=0)
    diem_b = Column(DECIMAL(8, 4), default=0)
    diem_c = Column(DECIMAL(8, 4), default=0)
    diem_d = Column(DECIMAL(8, 4))
    diem_dd = Column(DECIMAL(8, 4))
    diem_e = Column(DECIMAL(8, 4))
    diem_kpi = Column(DECIMAL(8, 4), default=0)
    diem_tieu_chi_chung = Column(DECIMAL(5, 2), default=30)
    tong_diem = Column(DECIMAL(5, 2), default=0)
    xep_loai = Column(String(50))
    trang_thai = Column(String(20), default='CHUA_TINH')
    ngay_tinh = Column(DateTime)
    ngay_tao = Column(DateTime, default=func.now())

class LogHeThong(Base):
    __tablename__ = "log_he_thong"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nguoi_dung_id = Column(UUID(as_uuid=True), ForeignKey("nguoi_dung.id"))
    hanh_dong = Column(String(100), nullable=False)
    doi_tuong = Column(String(100))
    doi_tuong_id = Column(UUID(as_uuid=True))
    mo_ta = Column(Text)
    ip_address = Column(String(50))
    ngay_tao = Column(DateTime, default=func.now())
