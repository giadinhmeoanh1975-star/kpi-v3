import { TrangThaiKeKhai, TrangThaiNhiemVu, TrangThaiNghiPhep, XepLoaiKPI } from '../types';

export const formatDate = (dateString: string): string => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString('vi-VN');
};

export const formatDateTime = (dateString: string): string => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString('vi-VN');
};

export const formatNumber = (num: number, decimals = 2): string => {
  return num.toLocaleString('vi-VN', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });
};

export const getMonthName = (month: number): string => {
  const months = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
    'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];
  return months[month - 1] || '';
};

export const getTrangThaiKeKhaiLabel = (status: TrangThaiKeKhai): string => {
  const labels: Record<TrangThaiKeKhai, string> = {
    NHAP: 'Nháp',
    CHO_DUYET: 'Chờ duyệt',
    DA_DUYET: 'Đã duyệt',
    TU_CHOI: 'Từ chối',
    YEU_CAU_SUA: 'Yêu cầu sửa',
  };
  return labels[status] || status;
};

export const getTrangThaiKeKhaiColor = (status: TrangThaiKeKhai): string => {
  const colors: Record<TrangThaiKeKhai, string> = {
    NHAP: 'bg-gray-100 text-gray-800',
    CHO_DUYET: 'bg-yellow-100 text-yellow-800',
    DA_DUYET: 'bg-green-100 text-green-800',
    TU_CHOI: 'bg-red-100 text-red-800',
    YEU_CAU_SUA: 'bg-orange-100 text-orange-800',
  };
  return colors[status] || 'bg-gray-100 text-gray-800';
};

export const getTrangThaiNhiemVuLabel = (status: TrangThaiNhiemVu): string => {
  const labels: Record<TrangThaiNhiemVu, string> = {
    MOI_GIAO: 'Mới giao',
    DANG_THUC_HIEN: 'Đang thực hiện',
    HOAN_THANH: 'Hoàn thành',
    DA_DANH_GIA: 'Đã đánh giá',
    HUY: 'Đã hủy',
  };
  return labels[status] || status;
};

export const getTrangThaiNhiemVuColor = (status: TrangThaiNhiemVu): string => {
  const colors: Record<TrangThaiNhiemVu, string> = {
    MOI_GIAO: 'bg-blue-100 text-blue-800',
    DANG_THUC_HIEN: 'bg-yellow-100 text-yellow-800',
    HOAN_THANH: 'bg-green-100 text-green-800',
    DA_DANH_GIA: 'bg-purple-100 text-purple-800',
    HUY: 'bg-gray-100 text-gray-800',
  };
  return colors[status] || 'bg-gray-100 text-gray-800';
};

export const getTrangThaiNghiPhepLabel = (status: TrangThaiNghiPhep): string => {
  const labels: Record<TrangThaiNghiPhep, string> = {
    CHO_DUYET: 'Chờ duyệt',
    DA_DUYET: 'Đã duyệt',
    TU_CHOI: 'Từ chối',
  };
  return labels[status] || status;
};

export const getXepLoaiKPILabel = (xepLoai: XepLoaiKPI): string => {
  const labels: Record<XepLoaiKPI, string> = {
    XS: 'Xuất sắc',
    T: 'Tốt',
    KT: 'Khá tốt',
    Y: 'Yếu',
  };
  return labels[xepLoai] || xepLoai;
};

export const getXepLoaiKPIColor = (xepLoai: XepLoaiKPI): string => {
  const colors: Record<XepLoaiKPI, string> = {
    XS: 'bg-green-500 text-white',
    T: 'bg-blue-500 text-white',
    KT: 'bg-yellow-500 text-white',
    Y: 'bg-red-500 text-white',
  };
  return colors[xepLoai] || 'bg-gray-500 text-white';
};

export const cn = (...classes: (string | boolean | undefined)[]): string => {
  return classes.filter(Boolean).join(' ');
};

export const debounce = <T extends (...args: unknown[]) => unknown>(
  func: T,
  wait: number
): ((...args: Parameters<T>) => void) => {
  let timeout: NodeJS.Timeout;
  return (...args: Parameters<T>) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => func(...args), wait);
  };
};
