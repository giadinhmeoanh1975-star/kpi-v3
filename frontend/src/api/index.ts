import {
  LoginResponse,
  DonVi,
  ChucVu,
  SanPham,
  MucDo,
  HeSo,
  NgayLe,
  NguoiDung,
  KeKhai,
  KeKhaiCreate,
  KeKhaiThongKe,
  NhiemVu,
  NhiemVuCreate,
  TieuChiChung,
  TieuChiChungCreate,
  NghiPhep,
  NghiPhepCreate,
  KPIThang,
  LanhDaoPhuTrach,
} from '../types';

const API_BASE = '/api';

class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

async function request<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = localStorage.getItem('token');
  const headers: HeadersInit = {
    'Content-Type': 'application/json',
    ...(token && { Authorization: `Bearer ${token}` }),
    ...options.headers,
  };

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers,
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: 'Lỗi không xác định' }));
    throw new ApiError(response.status, error.detail || 'Lỗi không xác định');
  }

  return response.json();
}

// Auth API
export const authApi = {
  login: (ma_cong_chuc: string, mat_khau: string) =>
    request<LoginResponse>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ ma_cong_chuc, mat_khau }),
    }),

  me: () => request<LoginResponse['user']>('/auth/me'),

  changePassword: (mat_khau_cu: string, mat_khau_moi: string) =>
    request<{ message: string }>('/auth/change-password', {
      method: 'POST',
      body: JSON.stringify({ mat_khau_cu, mat_khau_moi }),
    }),
};

// Danh mục API
export const danhMucApi = {
  getDonVi: () => request<DonVi[]>('/danh-muc/don-vi'),
  getChucVu: () => request<ChucVu[]>('/danh-muc/chuc-vu'),
  getSanPham: () => request<SanPham[]>('/danh-muc/san-pham'),
  getMucDo: () => request<MucDo[]>('/danh-muc/muc-do'),
  getHeSo: () => request<HeSo[]>('/danh-muc/he-so'),
  getNgayLe: (nam?: number) =>
    request<NgayLe[]>(`/danh-muc/ngay-le${nam ? `?nam=${nam}` : ''}`),
  getNguoiDung: (params?: { don_vi_id?: number; chuc_vu_id?: number }) => {
    const searchParams = new URLSearchParams();
    if (params?.don_vi_id) searchParams.set('don_vi_id', params.don_vi_id.toString());
    if (params?.chuc_vu_id) searchParams.set('chuc_vu_id', params.chuc_vu_id.toString());
    return request<NguoiDung[]>(`/danh-muc/nguoi-dung?${searchParams}`);
  },
  getLanhDaoPheduyet: () => request<LanhDaoPhuTrach[]>('/danh-muc/lanh-dao-phe-duyet'),
  lookupHeSo: (san_pham_id: number, muc_do_id: number) =>
    request<{ he_so: number }>(`/danh-muc/he-so/lookup?san_pham_id=${san_pham_id}&muc_do_id=${muc_do_id}`),
};

// Kê khai API
export const keKhaiApi = {
  getMyKeKhai: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<KeKhai[]>(`/ke-khai/cua-toi?${params}`);
  },

  create: (data: KeKhaiCreate) =>
    request<KeKhai>('/ke-khai', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  update: (id: number, data: Partial<KeKhaiCreate>) =>
    request<KeKhai>(`/ke-khai/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  delete: (id: number) =>
    request<{ message: string }>(`/ke-khai/${id}`, { method: 'DELETE' }),

  submit: () =>
    request<{ message: string; so_luong: number }>('/ke-khai/gui', {
      method: 'POST',
    }),

  getThongKe: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<KeKhaiThongKe>(`/ke-khai/thong-ke?${params}`);
  },
};

// Phê duyệt API
export const pheDuyetApi = {
  getChoDuyet: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<KeKhai[]>(`/phe-duyet/cho-duyet?${params}`);
  },

  getDaDuyet: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<KeKhai[]>(`/phe-duyet/da-duyet?${params}`);
  },

  approve: (id: number, hanh_dong: 'duyet' | 'tu_choi' | 'yeu_cau_sua', ghi_chu?: string) =>
    request<KeKhai>(`/phe-duyet/${id}`, {
      method: 'POST',
      body: JSON.stringify({ hanh_dong, ghi_chu }),
    }),

  batchApprove: (ids: number[], hanh_dong: 'duyet' | 'tu_choi', ghi_chu?: string) =>
    request<{ success: number; failed: number }>('/phe-duyet/batch', {
      method: 'POST',
      body: JSON.stringify({ ids, hanh_dong, ghi_chu }),
    }),

  getThongKe: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<{ cho_duyet: number; da_duyet: number; tu_choi: number }>(`/phe-duyet/thong-ke?${params}`);
  },
};

// Nhiệm vụ API
export const nhiemVuApi = {
  getDaGiao: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<NhiemVu[]>(`/nhiem-vu/da-giao?${params}`);
  },

  getDuocGiao: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<NhiemVu[]>(`/nhiem-vu/duoc-giao?${params}`);
  },

  getNguoiCoTheGiao: () =>
    request<NguoiDung[]>('/nhiem-vu/nguoi-co-the-giao'),

  create: (data: NhiemVuCreate) =>
    request<NhiemVu>('/nhiem-vu', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  update: (id: number, data: Partial<NhiemVuCreate>) =>
    request<NhiemVu>(`/nhiem-vu/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  delete: (id: number) =>
    request<{ message: string }>(`/nhiem-vu/${id}`, { method: 'DELETE' }),

  tuDanhGia: (id: number, tu_danh_gia: string, diem_tu_danh_gia: number) =>
    request<NhiemVu>(`/nhiem-vu/${id}/tu-danh-gia`, {
      method: 'POST',
      body: JSON.stringify({ tu_danh_gia, diem_tu_danh_gia }),
    }),

  danhGia: (id: number, danh_gia_lanh_dao: string, diem_lanh_dao: number) =>
    request<NhiemVu>(`/nhiem-vu/${id}/danh-gia`, {
      method: 'POST',
      body: JSON.stringify({ danh_gia_lanh_dao, diem_lanh_dao }),
    }),
};

// Tiêu chí API
export const tieuChiApi = {
  getMyTieuChi: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<TieuChiChung | null>(`/tieu-chi/cua-toi?${params}`);
  },

  create: (data: TieuChiChungCreate) =>
    request<TieuChiChung>('/tieu-chi', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  update: (id: number, data: TieuChiChungCreate) =>
    request<TieuChiChung>(`/tieu-chi/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  getDanhGiaCapDuoi: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<TieuChiChung[]>(`/tieu-chi/cap-duoi?${params}`);
  },

  danhGia: (nguoi_dung_id: number, data: TieuChiChungCreate) =>
    request<TieuChiChung>(`/tieu-chi/danh-gia/${nguoi_dung_id}`, {
      method: 'POST',
      body: JSON.stringify(data),
    }),
};

// Nghỉ phép API
export const nghiPhepApi = {
  getMyNghiPhep: (nam?: number) => {
    const params = new URLSearchParams();
    if (nam) params.set('nam', nam.toString());
    return request<NghiPhep[]>(`/nghi-phep/cua-toi?${params}`);
  },

  create: (data: NghiPhepCreate) =>
    request<NghiPhep>('/nghi-phep', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  delete: (id: number) =>
    request<{ message: string }>(`/nghi-phep/${id}`, { method: 'DELETE' }),

  getChoDuyet: () => request<NghiPhep[]>('/nghi-phep/cho-duyet'),

  approve: (id: number, hanh_dong: 'duyet' | 'tu_choi', ghi_chu?: string) =>
    request<NghiPhep>(`/nghi-phep/${id}/duyet`, {
      method: 'POST',
      body: JSON.stringify({ hanh_dong, ghi_chu }),
    }),
};

// KPI API
export const kpiApi = {
  getMyKPI: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<KPIThang | null>(`/kpi/cua-toi?${params}`);
  },

  calculate: (thang: number, nam: number) =>
    request<KPIThang>('/kpi/tinh', {
      method: 'POST',
      body: JSON.stringify({ thang, nam }),
    }),

  getDonVi: (don_vi_id: number, thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    params.set('don_vi_id', don_vi_id.toString());
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<KPIThang[]>(`/kpi/don-vi?${params}`);
  },

  getAll: (thang?: number, nam?: number) => {
    const params = new URLSearchParams();
    if (thang) params.set('thang', thang.toString());
    if (nam) params.set('nam', nam.toString());
    return request<KPIThang[]>(`/kpi/tat-ca?${params}`);
  },

  export: (thang: number, nam: number) =>
    request<{ url: string }>(`/kpi/xuat-excel?thang=${thang}&nam=${nam}`),
};

// Admin API
export const adminApi = {
  getUsers: (params?: { don_vi_id?: number; trang_thai?: boolean; search?: string }) => {
    const searchParams = new URLSearchParams();
    if (params?.don_vi_id) searchParams.set('don_vi_id', params.don_vi_id.toString());
    if (params?.trang_thai !== undefined) searchParams.set('trang_thai', params.trang_thai.toString());
    if (params?.search) searchParams.set('search', params.search);
    return request<NguoiDung[]>(`/admin/nguoi-dung?${searchParams}`);
  },

  createUser: (data: Partial<NguoiDung>) =>
    request<NguoiDung>('/admin/nguoi-dung', {
      method: 'POST',
      body: JSON.stringify(data),
    }),

  updateUser: (id: number, data: Partial<NguoiDung>) =>
    request<NguoiDung>(`/admin/nguoi-dung/${id}`, {
      method: 'PUT',
      body: JSON.stringify(data),
    }),

  resetPassword: (id: number) =>
    request<{ message: string }>(`/admin/nguoi-dung/${id}/reset-password`, {
      method: 'POST',
    }),

  toggleStatus: (id: number) =>
    request<NguoiDung>(`/admin/nguoi-dung/${id}/toggle-status`, {
      method: 'POST',
    }),

  getDashboard: () =>
    request<{
      tong_nguoi_dung: number;
      nguoi_dung_hoat_dong: number;
      ke_khai_thang_nay: number;
      kpi_da_tinh: number;
    }>('/admin/dashboard'),
};

export { ApiError };
