import React, { useEffect, useState, useCallback } from 'react';
import { useAppStore, useDanhMucStore, useNotificationStore } from '../store';
import { Card, Button, Modal, Table, Badge, Spinner, EmptyState, Textarea, Tabs } from '../components';
import { pheDuyetApi } from '../api';
import { KeKhai } from '../types';
import { getTrangThaiKeKhaiLabel, getTrangThaiKeKhaiColor, formatDate, formatNumber } from '../utils';

export const PheDuyetPage: React.FC = () => {
  const { currentMonth, currentYear } = useAppStore();
  const { sanPham, mucDo, fetchAll, loaded } = useDanhMucStore();
  const { addNotification } = useNotificationStore();

  const [choDuyetList, setChoDuyetList] = useState<KeKhai[]>([]);
  const [daDuyetList, setDaDuyetList] = useState<KeKhai[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedIds, setSelectedIds] = useState<number[]>([]);
  const [approvalModal, setApprovalModal] = useState<{
    isOpen: boolean;
    item: KeKhai | null;
    action: 'duyet' | 'tu_choi' | 'yeu_cau_sua';
  }>({ isOpen: false, item: null, action: 'duyet' });
  const [ghiChu, setGhiChu] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const [choDuyet, daDuyet] = await Promise.all([
        pheDuyetApi.getChoDuyet(currentMonth, currentYear),
        pheDuyetApi.getDaDuyet(currentMonth, currentYear),
      ]);
      setChoDuyetList(choDuyet);
      setDaDuyetList(daDuyet);
    } catch (error) {
      console.error('Failed to load data:', error);
      addNotification('error', 'Không thể tải dữ liệu');
    } finally {
      setLoading(false);
    }
  }, [currentMonth, currentYear, addNotification]);

  useEffect(() => {
    if (!loaded) fetchAll();
    loadData();
  }, [loaded, fetchAll, loadData]);

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedIds(choDuyetList.map(k => k.id));
    } else {
      setSelectedIds([]);
    }
  };

  const handleSelectOne = (id: number, checked: boolean) => {
    if (checked) {
      setSelectedIds([...selectedIds, id]);
    } else {
      setSelectedIds(selectedIds.filter(i => i !== id));
    }
  };

  const handleOpenApprovalModal = (item: KeKhai, action: 'duyet' | 'tu_choi' | 'yeu_cau_sua') => {
    setApprovalModal({ isOpen: true, item, action });
    setGhiChu('');
  };

  const handleCloseApprovalModal = () => {
    setApprovalModal({ isOpen: false, item: null, action: 'duyet' });
    setGhiChu('');
  };

  const handleApprove = async () => {
    if (!approvalModal.item) return;

    setSubmitting(true);
    try {
      await pheDuyetApi.approve(approvalModal.item.id, approvalModal.action, ghiChu || undefined);
      const actionLabels = { duyet: 'Phê duyệt', tu_choi: 'Từ chối', yeu_cau_sua: 'Yêu cầu sửa' };
      addNotification('success', `${actionLabels[approvalModal.action]} thành công`);
      handleCloseApprovalModal();
      loadData();
    } catch (error) {
      addNotification('error', 'Có lỗi xảy ra');
    } finally {
      setSubmitting(false);
    }
  };

  const handleBatchApprove = async (action: 'duyet' | 'tu_choi') => {
    if (selectedIds.length === 0) {
      addNotification('warning', 'Vui lòng chọn ít nhất một kê khai');
      return;
    }

    const actionLabel = action === 'duyet' ? 'phê duyệt' : 'từ chối';
    if (!confirm(`${action === 'duyet' ? 'Phê duyệt' : 'Từ chối'} ${selectedIds.length} kê khai đã chọn?`)) return;

    setSubmitting(true);
    try {
      const result = await pheDuyetApi.batchApprove(selectedIds, action);
      addNotification('success', `Đã ${actionLabel} ${result.success} kê khai`);
      setSelectedIds([]);
      loadData();
    } catch (error) {
      addNotification('error', 'Có lỗi xảy ra');
    } finally {
      setSubmitting(false);
    }
  };

  const getSanPhamName = (id: number) => sanPham.find(s => s.id === id)?.ten_san_pham || '';
  const getMucDoName = (id: number) => mucDo.find(m => m.id === id)?.ten_muc_do || '';

  const choDuyetColumns = [
    {
      key: 'select',
      title: (
        <input
          type="checkbox"
          checked={selectedIds.length === choDuyetList.length && choDuyetList.length > 0}
          onChange={(e) => handleSelectAll(e.target.checked)}
          className="rounded border-gray-300"
        />
      ),
      render: (item: KeKhai) => (
        <input
          type="checkbox"
          checked={selectedIds.includes(item.id)}
          onChange={(e) => handleSelectOne(item.id, e.target.checked)}
          className="rounded border-gray-300"
        />
      ),
    },
    {
      key: 'nguoi_khai',
      title: 'Người kê khai',
      render: (item: KeKhai) => (
        <div>
          <p className="font-medium">{item.nguoi_dung?.ho_ten}</p>
          <p className="text-xs text-gray-500">{item.nguoi_dung?.ma_cong_chuc}</p>
        </div>
      ),
    },
    {
      key: 'ngay_thuc_hien',
      title: 'Ngày',
      render: (item: KeKhai) => formatDate(item.ngay_thuc_hien),
    },
    {
      key: 'san_pham',
      title: 'Sản phẩm',
      render: (item: KeKhai) => getSanPhamName(item.san_pham_id),
    },
    {
      key: 'muc_do',
      title: 'Mức độ',
      render: (item: KeKhai) => getMucDoName(item.muc_do_id),
    },
    {
      key: 'so_luong',
      title: 'SL',
      className: 'text-center',
    },
    {
      key: 'diem_quy_doi',
      title: 'Điểm',
      render: (item: KeKhai) => formatNumber(item.diem_quy_doi),
    },
    {
      key: 'mo_ta',
      title: 'Mô tả',
      render: (item: KeKhai) => (
        <span className="text-sm text-gray-600 truncate max-w-xs block">
          {item.mo_ta || '-'}
        </span>
      ),
    },
    {
      key: 'actions',
      title: 'Thao tác',
      render: (item: KeKhai) => (
        <div className="flex gap-1">
          <button
            onClick={() => handleOpenApprovalModal(item, 'duyet')}
            className="px-2 py-1 text-xs bg-green-100 text-green-700 rounded hover:bg-green-200"
          >
            Duyệt
          </button>
          <button
            onClick={() => handleOpenApprovalModal(item, 'yeu_cau_sua')}
            className="px-2 py-1 text-xs bg-yellow-100 text-yellow-700 rounded hover:bg-yellow-200"
          >
            Sửa
          </button>
          <button
            onClick={() => handleOpenApprovalModal(item, 'tu_choi')}
            className="px-2 py-1 text-xs bg-red-100 text-red-700 rounded hover:bg-red-200"
          >
            Từ chối
          </button>
        </div>
      ),
    },
  ];

  const daDuyetColumns = [
    {
      key: 'nguoi_khai',
      title: 'Người kê khai',
      render: (item: KeKhai) => (
        <div>
          <p className="font-medium">{item.nguoi_dung?.ho_ten}</p>
          <p className="text-xs text-gray-500">{item.nguoi_dung?.ma_cong_chuc}</p>
        </div>
      ),
    },
    {
      key: 'ngay_thuc_hien',
      title: 'Ngày TH',
      render: (item: KeKhai) => formatDate(item.ngay_thuc_hien),
    },
    {
      key: 'san_pham',
      title: 'Sản phẩm',
      render: (item: KeKhai) => getSanPhamName(item.san_pham_id),
    },
    {
      key: 'diem_quy_doi',
      title: 'Điểm',
      render: (item: KeKhai) => formatNumber(item.diem_quy_doi),
    },
    {
      key: 'trang_thai',
      title: 'Trạng thái',
      render: (item: KeKhai) => (
        <Badge className={getTrangThaiKeKhaiColor(item.trang_thai)}>
          {getTrangThaiKeKhaiLabel(item.trang_thai)}
        </Badge>
      ),
    },
    {
      key: 'ngay_duyet',
      title: 'Ngày duyệt',
      render: (item: KeKhai) => formatDate(item.ngay_duyet || ''),
    },
    {
      key: 'ghi_chu',
      title: 'Ghi chú',
      render: (item: KeKhai) => item.ghi_chu_duyet || '-',
    },
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Spinner size="lg" />
      </div>
    );
  }

  const tabs = [
    {
      key: 'cho_duyet',
      label: `Chờ duyệt (${choDuyetList.length})`,
      content: (
        <div>
          {selectedIds.length > 0 && (
            <div className="mb-4 p-4 bg-blue-50 rounded-lg flex items-center justify-between">
              <span className="text-sm text-blue-700">
                Đã chọn {selectedIds.length} kê khai
              </span>
              <div className="flex gap-2">
                <Button
                  size="sm"
                  onClick={() => handleBatchApprove('duyet')}
                  loading={submitting}
                >
                  Duyệt tất cả
                </Button>
                <Button
                  size="sm"
                  variant="danger"
                  onClick={() => handleBatchApprove('tu_choi')}
                  loading={submitting}
                >
                  Từ chối tất cả
                </Button>
              </div>
            </div>
          )}
          {choDuyetList.length === 0 ? (
            <EmptyState
              title="Không có kê khai nào chờ duyệt"
              description="Các kê khai cần phê duyệt sẽ hiển thị ở đây"
            />
          ) : (
            <Table
              columns={choDuyetColumns}
              data={choDuyetList}
              rowKey={(item) => item.id}
            />
          )}
        </div>
      ),
    },
    {
      key: 'da_duyet',
      label: `Đã xử lý (${daDuyetList.length})`,
      content: (
        <div>
          {daDuyetList.length === 0 ? (
            <EmptyState
              title="Chưa có kê khai nào được xử lý"
              description="Các kê khai đã phê duyệt hoặc từ chối sẽ hiển thị ở đây"
            />
          ) : (
            <Table
              columns={daDuyetColumns}
              data={daDuyetList}
              rowKey={(item) => item.id}
            />
          )}
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="!p-4">
          <p className="text-sm text-gray-500">Chờ phê duyệt</p>
          <p className="text-2xl font-bold text-yellow-600">{choDuyetList.length}</p>
        </Card>
        <Card className="!p-4">
          <p className="text-sm text-gray-500">Đã duyệt</p>
          <p className="text-2xl font-bold text-green-600">
            {daDuyetList.filter(k => k.trang_thai === 'DA_DUYET').length}
          </p>
        </Card>
        <Card className="!p-4">
          <p className="text-sm text-gray-500">Đã từ chối</p>
          <p className="text-2xl font-bold text-red-600">
            {daDuyetList.filter(k => k.trang_thai === 'TU_CHOI').length}
          </p>
        </Card>
      </div>

      {/* Main Content */}
      <Card title={`Phê duyệt kê khai - Tháng ${currentMonth}/${currentYear}`}>
        <Tabs tabs={tabs} />
      </Card>

      {/* Approval Modal */}
      <Modal
        isOpen={approvalModal.isOpen}
        onClose={handleCloseApprovalModal}
        title={
          approvalModal.action === 'duyet'
            ? 'Phê duyệt kê khai'
            : approvalModal.action === 'tu_choi'
            ? 'Từ chối kê khai'
            : 'Yêu cầu sửa kê khai'
        }
      >
        {approvalModal.item && (
          <div className="space-y-4">
            <div className="bg-gray-50 p-4 rounded-lg space-y-2">
              <p><strong>Người kê khai:</strong> {approvalModal.item.nguoi_dung?.ho_ten}</p>
              <p><strong>Sản phẩm:</strong> {getSanPhamName(approvalModal.item.san_pham_id)}</p>
              <p><strong>Mức độ:</strong> {getMucDoName(approvalModal.item.muc_do_id)}</p>
              <p><strong>Số lượng:</strong> {approvalModal.item.so_luong}</p>
              <p><strong>Điểm quy đổi:</strong> {formatNumber(approvalModal.item.diem_quy_doi)}</p>
              {approvalModal.item.mo_ta && (
                <p><strong>Mô tả:</strong> {approvalModal.item.mo_ta}</p>
              )}
            </div>

            {(approvalModal.action === 'tu_choi' || approvalModal.action === 'yeu_cau_sua') && (
              <Textarea
                label="Lý do *"
                value={ghiChu}
                onChange={(e) => setGhiChu(e.target.value)}
                rows={3}
                placeholder={approvalModal.action === 'tu_choi' ? 'Nhập lý do từ chối...' : 'Nhập yêu cầu sửa...'}
              />
            )}

            {approvalModal.action === 'duyet' && (
              <Textarea
                label="Ghi chú (không bắt buộc)"
                value={ghiChu}
                onChange={(e) => setGhiChu(e.target.value)}
                rows={2}
                placeholder="Nhập ghi chú nếu cần..."
              />
            )}

            <div className="flex justify-end gap-2 pt-4">
              <Button variant="secondary" onClick={handleCloseApprovalModal}>
                Hủy
              </Button>
              <Button
                variant={approvalModal.action === 'tu_choi' ? 'danger' : 'primary'}
                onClick={handleApprove}
                loading={submitting}
                disabled={(approvalModal.action === 'tu_choi' || approvalModal.action === 'yeu_cau_sua') && !ghiChu}
              >
                {approvalModal.action === 'duyet'
                  ? 'Phê duyệt'
                  : approvalModal.action === 'tu_choi'
                  ? 'Từ chối'
                  : 'Yêu cầu sửa'}
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};
