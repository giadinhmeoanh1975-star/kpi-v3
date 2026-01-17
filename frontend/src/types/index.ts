// Types for KPI Management System v3.0

export interface DonVi {
  id: number;
  ma_don_vi: string;
  ten_don_vi: string;
  don_vi_cha_id: number | null;
}

export interface ChucVu {
  id: number;
  ma_chuc_vu: string;
  ten_chuc_vu: string;
  cap_lanh_dao: number;
  co_the_phe_duyet: boolean;
}

export interface NguoiDung {
  id: number;
  ma_cong_chuc: string;
  ho_ten: string;
  nam_sinh: string | null;
  don_vi_id: number;
  chuc_vu_id: number;
  la_admin: boolean;
  la_tccb: boolean;
  trang_thai: boolean;
  don_vi?: DonVi;
  chuc_vu?: ChucVu;
}

export interface LoginResponse {
  access_token: string;
  token_type: string;
  user: NguoiDung & {
    cap_lanh_dao: number;
    co_the_phe_duyet: boolean;
    don_vi_ten: string;
    chuc_vu_ten: string;
  };
}

export interface SanPham {
  id: number;
  ma_san_pham: string;
  ten_san_pham: string;
  don_vi_tinh: string;
  mo_ta: string | null;
}

export interface MucDo {
  id: number;
  ten_muc_do: string;
  mo_ta: string;
}

export interface HeSo {
  id: number;
  san_pham_id: number;
  muc_do_id: number;
  he_so: number;
}

export interface NgayLe {
  id: number;
  ngay: string;
  ten_ngay_le: string;
  nam: number;
}

export type TrangThaiKeKhai = 'NHAP' | 'CHO_DUYET' | 'DA_DUYET' | 'TU_CHOI' | 'YEU_CAU_SUA';

export interface KeKhai {
  id: number;
  nguoi_dung_id: number;
  thang: number;
  nam: number;
  san_pham_id: number;
  muc_do_id: number;
  so_luong: number;
  he_so: number;
  he_so_tu_nhap: number | null;
  diem_quy_doi: number;
  ngay_thuc_hien: string;
  mo_ta: string | null;
  trang_thai: TrangThaiKeKhai;
  lanh_dao_phe_duyet_id: number | null;
  lanh_dao_phe_duyet_ten?: string;
  nguoi_duyet_id: number | null;
  ngay_duyet: string | null;
  ghi_chu_duyet: string | null;
  nguoi_dung?: NguoiDung;
  san_pham?: SanPham;
  muc_do?: MucDo;
}

export interface KeKhaiCreate {
  san_pham_id: number;
  muc_do_id: number;
  so_luong: number;
  ngay_thuc_hien: string;
  mo_ta?: string;
  lanh_dao_phe_duyet_id: number;
  he_so_tu_nhap?: number;
}

export interface KeKhaiThongKe {
  tong_ke_khai: number;
  da_duyet: number;
  cho_duyet: number;
  tu_choi: number;
  tong_diem: number;
}

export type TrangThaiNhiemVu = 'MOI_GIAO' | 'DANG_THUC_HIEN' | 'HOAN_THANH' | 'DA_DANH_GIA' | 'HUY';

export interface NhiemVu {
  id: number;
  nguoi_giao_id: number;
  nguoi_nhan_id: number;
  thang: number;
  nam: number;
  noi_dung: string;
  han_hoan_thanh: string | null;
  trang_thai: TrangThaiNhiemVu;
  tu_danh_gia: string | null;
  diem_tu_danh_gia: number | null;
  danh_gia_lanh_dao: string | null;
  diem_lanh_dao: number | null;
  ngay_tao: string;
  nguoi_giao?: NguoiDung;
  nguoi_nhan?: NguoiDung;
}

export interface NhiemVuCreate {
  nguoi_nhan_id: number;
  noi_dung: string;
  han_hoan_thanh?: string;
}

export interface TieuChiChung {
  id: number;
  nguoi_dung_id: number;
  thang: number;
  nam: number;
  tc1_cham_cong: number;
  tc2_ky_luat: number;
  tc3_phoi_hop: number;
  tc4_thai_do: number;
  tc5_hoc_tap: number;
  tc6_sang_kien: number;
  tong_diem: number;
  nguoi_danh_gia_id: number | null;
  ngay_danh_gia: string | null;
}

export interface TieuChiChungCreate {
  tc1_cham_cong: number;
  tc2_ky_luat: number;
  tc3_phoi_hop: number;
  tc4_thai_do: number;
  tc5_hoc_tap: number;
  tc6_sang_kien: number;
}

export type XepLoaiLanhDao = 'D' | 'Đ' | 'E';

export interface DiemLanhDao {
  id: number;
  nguoi_dung_id: number;
  thang: number;
  nam: number;
  xep_loai: XepLoaiLanhDao;
  nhan_xet: string | null;
  nguoi_danh_gia_id: number;
  ngay_danh_gia: string;
}

export type TrangThaiNghiPhep = 'CHO_DUYET' | 'DA_DUYET' | 'TU_CHOI';

export interface NghiPhep {
  id: number;
  nguoi_dung_id: number;
  thang: number;
  nam: number;
  ngay_bat_dau: string;
  ngay_ket_thuc: string;
  so_ngay: number;
  ly_do: string;
  loai_nghi: string;
  trang_thai: TrangThaiNghiPhep;
  nguoi_duyet_id: number | null;
  ngay_duyet: string | null;
  ghi_chu: string | null;
  nguoi_dung?: NguoiDung;
}

export interface NghiPhepCreate {
  ngay_bat_dau: string;
  ngay_ket_thuc: string;
  ly_do: string;
  loai_nghi: string;
}

export type XepLoaiKPI = 'XS' | 'T' | 'KT' | 'Y';

export interface KPIThang {
  id: number;
  nguoi_dung_id: number;
  thang: number;
  nam: number;
  diem_san_pham: number;
  diem_nhiem_vu: number;
  diem_tieu_chi: number;
  diem_lanh_dao: number;
  he_so_nghi_phep: number;
  tong_diem: number;
  xep_loai: XepLoaiKPI;
  nguoi_dung?: NguoiDung;
}

export interface TruongHopDacBiet {
  id: number;
  nguoi_dung_id: number;
  thang: number;
  nam: number;
  loai: string;
  ly_do: string;
  diem_dieu_chinh: number | null;
  xep_loai_dieu_chinh: XepLoaiKPI | null;
  nguoi_duyet_id: number | null;
  trang_thai: TrangThaiNghiPhep;
}

export interface LanhDaoPhuTrach {
  id: number;
  ho_ten: string;
  chuc_vu_ten: string;
  cap_lanh_dao: number;
}
