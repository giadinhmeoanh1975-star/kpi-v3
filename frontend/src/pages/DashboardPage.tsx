import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuthStore, useAppStore, useDanhMucStore } from '../store';
import { Card, StatsCard, Spinner, Badge } from '../components';
import { keKhaiApi, pheDuyetApi, kpiApi } from '../api';
import { KeKhaiThongKe, KPIThang } from '../types';
import { getXepLoaiKPILabel, getXepLoaiKPIColor, formatNumber } from '../utils';

export const DashboardPage: React.FC = () => {
  const { user } = useAuthStore();
  const { currentMonth, currentYear } = useAppStore();
  const { fetchAll, loaded } = useDanhMucStore();
  const [loading, setLoading] = useState(true);
  const [keKhaiStats, setKeKhaiStats] = useState<KeKhaiThongKe | null>(null);
  const [pheDuyetStats, setPheDuyetStats] = useState<{ cho_duyet: number; da_duyet: number } | null>(null);
  const [kpiThang, setKpiThang] = useState<KPIThang | null>(null);

  useEffect(() => {
    if (!loaded) {
      fetchAll();
    }
  }, [loaded, fetchAll]);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      try {
        const [kkStats, kpi] = await Promise.all([
          keKhaiApi.getThongKe(currentMonth, currentYear),
          kpiApi.getMyKPI(currentMonth, currentYear).catch(() => null),
        ]);
        setKeKhaiStats(kkStats);
        setKpiThang(kpi);

        if (user?.co_the_phe_duyet) {
          const pdStats = await pheDuyetApi.getThongKe(currentMonth, currentYear);
          setPheDuyetStats(pdStats);
        }
      } catch (error) {
        console.error('Failed to load dashboard data:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, [currentMonth, currentYear, user?.co_the_phe_duyet]);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Spinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Welcome */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl p-6 text-white">
        <h1 className="text-2xl font-bold">Xin chào, {user?.ho_ten}!</h1>
        <p className="mt-1 text-blue-100">
          {user?.chuc_vu_ten} - {user?.don_vi_ten}
        </p>
        <p className="mt-2 text-sm text-blue-200">
          Tháng {currentMonth}/{currentYear}
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatsCard
          title="Tổng kê khai"
          value={keKhaiStats?.tong_ke_khai || 0}
          icon={
            <svg className="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          }
        />
        <StatsCard
          title="Đã duyệt"
          value={keKhaiStats?.da_duyet || 0}
          icon={
            <svg className="w-8 h-8 text-green-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          }
        />
        <StatsCard
          title="Chờ duyệt"
          value={keKhaiStats?.cho_duyet || 0}
          icon={
            <svg className="w-8 h-8 text-yellow-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          }
        />
        <StatsCard
          title="Tổng điểm"
          value={formatNumber(keKhaiStats?.tong_diem || 0)}
          icon={
            <svg className="w-8 h-8 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
            </svg>
          }
        />
      </div>

      {/* KPI Result & Approval Stats */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* KPI Card */}
        <Card title="Kết quả KPI tháng này">
          {kpiThang ? (
            <div className="space-y-4">
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Tổng điểm:</span>
                <span className="text-2xl font-bold text-gray-900">
                  {formatNumber(kpiThang.tong_diem)}
                </span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-gray-600">Xếp loại:</span>
                <Badge className={getXepLoaiKPIColor(kpiThang.xep_loai)}>
                  {getXepLoaiKPILabel(kpiThang.xep_loai)}
                </Badge>
              </div>
              <div className="pt-4 border-t border-gray-200 space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-500">Điểm sản phẩm:</span>
                  <span>{formatNumber(kpiThang.diem_san_pham)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">Điểm nhiệm vụ:</span>
                  <span>{formatNumber(kpiThang.diem_nhiem_vu)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">Điểm tiêu chí:</span>
                  <span>{formatNumber(kpiThang.diem_tieu_chi)}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-500">Điểm lãnh đạo:</span>
                  <span>{formatNumber(kpiThang.diem_lanh_dao)}</span>
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              <p>Chưa có kết quả KPI</p>
              <Link to="/kpi" className="text-blue-600 hover:underline mt-2 inline-block">
                Tính KPI ngay
              </Link>
            </div>
          )}
        </Card>

        {/* Approval Stats - Only for leaders */}
        {user?.co_the_phe_duyet && (
          <Card title="Phê duyệt">
            <div className="space-y-4">
              <div className="flex items-center justify-between p-4 bg-yellow-50 rounded-lg">
                <div>
                  <p className="text-sm text-yellow-800">Chờ phê duyệt</p>
                  <p className="text-2xl font-bold text-yellow-900">{pheDuyetStats?.cho_duyet || 0}</p>
                </div>
                <Link
                  to="/phe-duyet"
                  className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600"
                >
                  Xem ngay
                </Link>
              </div>
              <div className="flex items-center justify-between p-4 bg-green-50 rounded-lg">
                <div>
                  <p className="text-sm text-green-800">Đã phê duyệt tháng này</p>
                  <p className="text-2xl font-bold text-green-900">{pheDuyetStats?.da_duyet || 0}</p>
                </div>
              </div>
            </div>
          </Card>
        )}

        {/* Quick Actions - For non-leaders */}
        {!user?.co_the_phe_duyet && (
          <Card title="Thao tác nhanh">
            <div className="grid grid-cols-2 gap-4">
              <Link
                to="/ke-khai"
                className="flex flex-col items-center p-4 bg-blue-50 rounded-lg hover:bg-blue-100 transition-colors"
              >
                <svg className="w-8 h-8 text-blue-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                <span className="mt-2 text-sm font-medium text-blue-900">Thêm kê khai</span>
              </Link>
              <Link
                to="/nhiem-vu"
                className="flex flex-col items-center p-4 bg-purple-50 rounded-lg hover:bg-purple-100 transition-colors"
              >
                <svg className="w-8 h-8 text-purple-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                </svg>
                <span className="mt-2 text-sm font-medium text-purple-900">Nhiệm vụ</span>
              </Link>
              <Link
                to="/nghi-phep"
                className="flex flex-col items-center p-4 bg-green-50 rounded-lg hover:bg-green-100 transition-colors"
              >
                <svg className="w-8 h-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <span className="mt-2 text-sm font-medium text-green-900">Đăng ký nghỉ</span>
              </Link>
              <Link
                to="/tieu-chi"
                className="flex flex-col items-center p-4 bg-orange-50 rounded-lg hover:bg-orange-100 transition-colors"
              >
                <svg className="w-8 h-8 text-orange-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
                </svg>
                <span className="mt-2 text-sm font-medium text-orange-900">Tiêu chí chung</span>
              </Link>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
};
