import React, { useEffect, useState, useCallback } from 'react';
import { useAppStore, useDanhMucStore, useNotificationStore } from '../store';
import { Card, Button, Modal, Input, Select, Textarea, Table, Badge, Spinner, EmptyState } from '../components';
import { keKhaiApi, danhMucApi } from '../api';
import { KeKhai, KeKhaiCreate, LanhDaoPhuTrach } from '../types';
import { getTrangThaiKeKhaiLabel, getTrangThaiKeKhaiColor, formatDate, formatNumber } from '../utils';

export const KeKhaiPage: React.FC = () => {
  const { currentMonth, currentYear } = useAppStore();
  const { sanPham, mucDo, fetchAll, loaded, getHeSo } = useDanhMucStore();
  const { addNotification } = useNotificationStore();

  const [keKhaiList, setKeKhaiList] = useState<KeKhai[]>([]);
  const [lanhDaoList, setLanhDaoList] = useState<LanhDaoPhuTrach[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<KeKhai | null>(null);
  const [submitting, setSubmitting] = useState(false);

  // Form state
  const [formData, setFormData] = useState<KeKhaiCreate>({
    san_pham_id: 0,
    muc_do_id: 0,
    so_luong: 1,
    ngay_thuc_hien: new Date().toISOString().split('T')[0],
    mo_ta: '',
    lanh_dao_phe_duyet_id: 0,
  });
  const [calculatedHeSo, setCalculatedHeSo] = useState(0);
  const [calculatedDiem, setCalculatedDiem] = useState(0);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const [keKhai, lanhDao] = await Promise.all([
        keKhaiApi.getMyKeKhai(currentMonth, currentYear),
        danhMucApi.getLanhDaoPheduyet().catch(() => []),
      ]);
      setKeKhaiList(keKhai);
      setLanhDaoList(lanhDao);
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

  // Calculate hệ số and điểm when form changes
  useEffect(() => {
    if (formData.san_pham_id && formData.muc_do_id) {
      const heSo = getHeSo(formData.san_pham_id, formData.muc_do_id);
      setCalculatedHeSo(heSo);
      setCalculatedDiem(formData.so_luong * heSo);
    } else {
      setCalculatedHeSo(0);
      setCalculatedDiem(0);
    }
  }, [formData.san_pham_id, formData.muc_do_id, formData.so_luong, getHeSo]);

  const handleOpenModal = (item?: KeKhai) => {
    if (item) {
      setEditingItem(item);
      setFormData({
        san_pham_id: item.san_pham_id,
        muc_do_id: item.muc_do_id,
        so_luong: item.so_luong,
        ngay_thuc_hien: item.ngay_thuc_hien.split('T')[0],
        mo_ta: item.mo_ta || '',
        lanh_dao_phe_duyet_id: item.lanh_dao_phe_duyet_id || 0,
        he_so_tu_nhap: item.he_so_tu_nhap || undefined,
      });
    } else {
      setEditingItem(null);
      setFormData({
        san_pham_id: sanPham[0]?.id || 0,
        muc_do_id: mucDo[0]?.id || 0,
        so_luong: 1,
        ngay_thuc_hien: new Date().toISOString().split('T')[0],
        mo_ta: '',
        lanh_dao_phe_duyet_id: lanhDaoList[0]?.id || 0,
      });
    }
    setIsModalOpen(true);
  };

  const handleCloseModal = () => {
    setIsModalOpen(false);
    setEditingItem(null);
  };

  const handleSubmitForm = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.lanh_dao_phe_duyet_id) {
      addNotification('error', 'Vui lòng chọn lãnh đạo phê duyệt');
      return;
    }

    setSubmitting(true);
    try {
      if (editingItem) {
        await keKhaiApi.update(editingItem.id, formData);
        addNotification('success', 'Cập nhật thành công');
      } else {
        await keKhaiApi.create(formData);
        addNotification('success', 'Thêm mới thành công');
      }
      handleCloseModal();
      loadData();
    } catch (error) {
      addNotification('error', 'Có lỗi xảy ra');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Bạn có chắc muốn xóa kê khai này?')) return;
    try {
      await keKhaiApi.delete(id);
      addNotification('success', 'Xóa thành công');
      loadData();
    } catch (error) {
      addNotification('error', 'Không thể xóa');
    }
  };

  const handleSubmitAll = async () => {
    const draftCount = keKhaiList.filter(k => k.trang_thai === 'NHAP' || k.trang_thai === 'YEU_CAU_SUA').length;
    if (draftCount === 0) {
      addNotification('warning', 'Không có kê khai nào để gửi');
      return;
    }
    if (!confirm(`Gửi ${draftCount} kê khai để phê duyệt?`)) return;

    try {
      const result = await keKhaiApi.submit();
      addNotification('success', `Đã gửi ${result.so_luong} kê khai`);
      loadData();
    } catch (error) {
      addNotification('error', 'Không thể gửi kê khai');
    }
  };

  const columns = [
    {
      key: 'ngay_thuc_hien',
      title: 'Ngày',
      render: (item: KeKhai) => formatDate(item.ngay_thuc_hien),
    },
    {
      key: 'san_pham',
      title: 'Sản phẩm',
      render: (item: KeKhai) => sanPham.find(s => s.id === item.san_pham_id)?.ten_san_pham || '',
    },
    {
      key: 'muc_do',
      title: 'Mức độ',
      render: (item: KeKhai) => mucDo.find(m => m.id === item.muc_do_id)?.ten_muc_do || '',
    },
    {
      key: 'so_luong',
      title: 'SL',
      className: 'text-center',
    },
    {
      key: 'he_so',
      title: 'Hệ số',
      render: (item: KeKhai) => formatNumber(item.he_so_tu_nhap || item.he_so),
    },
    {
      key: 'diem_quy_doi',
      title: 'Điểm',
      render: (item: KeKhai) => formatNumber(item.diem_quy_doi),
    },
    {
      key: 'lanh_dao',
      title: 'Lãnh đạo duyệt',
      render: (item: KeKhai) => item.lanh_dao_phe_duyet_ten || '-',
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
      key: 'actions',
      title: '',
      render: (item: KeKhai) => (
        <div className="flex gap-2">
          {(item.trang_thai === 'NHAP' || item.trang_thai === 'TU_CHOI' || item.trang_thai === 'YEU_CAU_SUA') && (
            <>
              <button
                onClick={() => handleOpenModal(item)}
                className="text-blue-600 hover:text-blue-800"
              >
                Sửa
              </button>
              <button
                onClick={() => handleDelete(item.id)}
                className="text-red-600 hover:text-red-800"
              >
                Xóa
              </button>
            </>
          )}
        </div>
      ),
    },
  ];

  const draftCount = keKhaiList.filter(k => k.trang_thai === 'NHAP' || k.trang_thai === 'YEU_CAU_SUA').length;
  const totalPoints = keKhaiList.filter(k => k.trang_thai === 'DA_DUYET').reduce((sum, k) => sum + k.diem_quy_doi, 0);

  // Check if selected muc_do is "Đặc biệt" (id = 5)
  const isSpecialMucDo = formData.muc_do_id === 5 || mucDo.find(m => m.id === formData.muc_do_id)?.ten_muc_do?.toLowerCase().includes('đặc biệt');

  if (loading && !keKhaiList.length) {
    return (
      <div className="flex justify-center items-center h-64">
        <Spinner size="lg" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card className="!p-4">
          <p className="text-sm text-gray-500">Tổng kê khai</p>
          <p className="text-2xl font-bold">{keKhaiList.length}</p>
        </Card>
        <Card className="!p-4">
          <p className="text-sm text-gray-500">Chờ gửi</p>
          <p className="text-2xl font-bold text-yellow-600">{draftCount}</p>
        </Card>
        <Card className="!p-4">
          <p className="text-sm text-gray-500">Đã duyệt</p>
          <p className="text-2xl font-bold text-green-600">
            {keKhaiList.filter(k => k.trang_thai === 'DA_DUYET').length}
          </p>
        </Card>
        <Card className="!p-4">
          <p className="text-sm text-gray-500">Tổng điểm (đã duyệt)</p>
          <p className="text-2xl font-bold text-blue-600">{formatNumber(totalPoints)}</p>
        </Card>
      </div>

      {/* Main Content */}
      <Card
        title={`Kê khai sản phẩm - Tháng ${currentMonth}/${currentYear}`}
        actions={
          <div className="flex gap-2">
            {draftCount > 0 && (
              <Button variant="secondary" onClick={handleSubmitAll}>
                Gửi duyệt ({draftCount})
              </Button>
            )}
            <Button onClick={() => handleOpenModal()}>+ Thêm mới</Button>
          </div>
        }
      >
        {keKhaiList.length === 0 ? (
          <EmptyState
            title="Chưa có kê khai nào"
            description="Bắt đầu thêm kê khai sản phẩm công việc của bạn"
            action={<Button onClick={() => handleOpenModal()}>+ Thêm kê khai</Button>}
          />
        ) : (
          <Table
            columns={columns}
            data={keKhaiList}
            rowKey={(item) => item.id}
          />
        )}
      </Card>

      {/* Add/Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={handleCloseModal}
        title={editingItem ? 'Sửa kê khai' : 'Thêm kê khai mới'}
        size="lg"
      >
        <form onSubmit={handleSubmitForm} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <Select
              label="Sản phẩm *"
              value={formData.san_pham_id}
              onChange={(e) => setFormData({ ...formData, san_pham_id: Number(e.target.value) })}
              options={sanPham.map(s => ({ value: s.id, label: s.ten_san_pham }))}
            />
            <Select
              label="Mức độ phức tạp *"
              value={formData.muc_do_id}
              onChange={(e) => setFormData({ ...formData, muc_do_id: Number(e.target.value) })}
              options={mucDo.map(m => ({ value: m.id, label: m.ten_muc_do }))}
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <Input
              label="Số lượng *"
              type="number"
              min={1}
              value={formData.so_luong}
              onChange={(e) => setFormData({ ...formData, so_luong: Number(e.target.value) })}
            />
            <Input
              label="Ngày thực hiện *"
              type="date"
              value={formData.ngay_thuc_hien}
              onChange={(e) => setFormData({ ...formData, ngay_thuc_hien: e.target.value })}
            />
          </div>

          {/* Hệ số tự nhập cho mức độ đặc biệt */}
          {isSpecialMucDo && (
            <Input
              label="Hệ số tự nhập (mức độ đặc biệt) *"
              type="number"
              step="0.01"
              min="0.1"
              value={formData.he_so_tu_nhap || ''}
              onChange={(e) => setFormData({ ...formData, he_so_tu_nhap: Number(e.target.value) || undefined })}
              placeholder="Nhập hệ số cho công việc đặc biệt"
            />
          )}

          <Select
            label="Lãnh đạo phê duyệt *"
            value={formData.lanh_dao_phe_duyet_id}
            onChange={(e) => setFormData({ ...formData, lanh_dao_phe_duyet_id: Number(e.target.value) })}
            options={[
              { value: 0, label: '-- Chọn lãnh đạo --' },
              ...lanhDaoList.map(l => ({
                value: l.id,
                label: `${l.ho_ten} - ${l.chuc_vu_ten}`,
              })),
            ]}
          />

          <Textarea
            label="Mô tả công việc"
            value={formData.mo_ta}
            onChange={(e) => setFormData({ ...formData, mo_ta: e.target.value })}
            rows={3}
            placeholder="Mô tả chi tiết công việc..."
          />

          {/* Preview */}
          <div className="bg-gray-50 p-4 rounded-lg">
            <p className="text-sm text-gray-600">
              Hệ số: <strong>{isSpecialMucDo && formData.he_so_tu_nhap ? formData.he_so_tu_nhap : formatNumber(calculatedHeSo)}</strong>
            </p>
            <p className="text-sm text-gray-600">
              Điểm quy đổi: <strong className="text-blue-600">
                {formatNumber(formData.so_luong * (isSpecialMucDo && formData.he_so_tu_nhap ? formData.he_so_tu_nhap : calculatedHeSo))}
              </strong>
            </p>
          </div>

          <div className="flex justify-end gap-2 pt-4">
            <Button type="button" variant="secondary" onClick={handleCloseModal}>
              Hủy
            </Button>
            <Button type="submit" loading={submitting}>
              {editingItem ? 'Cập nhật' : 'Thêm mới'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  );
};
