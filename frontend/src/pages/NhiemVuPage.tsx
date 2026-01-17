import React, { useEffect, useState, useCallback } from 'react';
import { useAppStore, useAuthStore, useNotificationStore } from '../store';
import { Card, Button, Modal, Input, Select, Textarea, Table, Badge, Spinner, EmptyState, Tabs } from '../components';
import { nhiemVuApi } from '../api';
import { NhiemVu, NhiemVuCreate, NguoiDung } from '../types';
import { getTrangThaiNhiemVuLabel, getTrangThaiNhiemVuColor, formatDate } from '../utils';

export const NhiemVuPage: React.FC = () => {
  const { currentMonth, currentYear } = useAppStore();
  const { user } = useAuthStore();
  const { addNotification } = useNotificationStore();

  const [daGiaoList, setDaGiaoList] = useState<NhiemVu[]>([]);
  const [duocGiaoList, setDuocGiaoList] = useState<NhiemVu[]>([]);
  const [nguoiCoTheGiao, setNguoiCoTheGiao] = useState<NguoiDung[]>([]);
  const [loading, setLoading] = useState(true);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [selfAssessModal, setSelfAssessModal] = useState<{ isOpen: boolean; item: NhiemVu | null }>({ isOpen: false, item: null });
  const [evaluateModal, setEvaluateModal] = useState<{ isOpen: boolean; item: NhiemVu | null }>({ isOpen: false, item: null });
  const [submitting, setSubmitting] = useState(false);

  // Form states
  const [createForm, setCreateForm] = useState<NhiemVuCreate>({
    nguoi_nhan_id: 0,
    noi_dung: '',
    han_hoan_thanh: '',
  });
  const [selfAssessForm, setSelfAssessForm] = useState({ tu_danh_gia: '', diem_tu_danh_gia: 8 });
  const [evaluateForm, setEvaluateForm] = useState({ danh_gia_lanh_dao: '', diem_lanh_dao: 8 });

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const [daGiao, duocGiao, nguoiGiao] = await Promise.all([
        nhiemVuApi.getDaGiao(currentMonth, currentYear),
        nhiemVuApi.getDuocGiao(currentMonth, currentYear),
        nhiemVuApi.getNguoiCoTheGiao().catch(() => []),
      ]);
      setDaGiaoList(daGiao);
      setDuocGiaoList(duocGiao);
      setNguoiCoTheGiao(nguoiGiao);
    } catch (error) {
      console.error('Failed to load data:', error);
      addNotification('error', 'Không thể tải dữ liệu');
    } finally {
      setLoading(false);
    }
  }, [currentMonth, currentYear, addNotification]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleCreateTask = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!createForm.nguoi_nhan_id || !createForm.noi_dung) {
      addNotification('error', 'Vui lòng điền đầy đủ thông tin');
      return;
    }

    setSubmitting(true);
    try {
      await nhiemVuApi.create(createForm);
      addNotification('success', 'Giao nhiệm vụ thành công');
      setIsCreateModalOpen(false);
      setCreateForm({ nguoi_nhan_id: 0, noi_dung: '', han_hoan_thanh: '' });
      loadData();
    } catch (error) {
      addNotification('error', 'Có lỗi xảy ra');
    } finally {
      setSubmitting(false);
    }
  };

  const handleSelfAssess = async () => {
    if (!selfAssessModal.item) return;
    
    setSubmitting(true);
    try {
      await nhiemVuApi.tuDanhGia(
        selfAssessModal.item.id,
        selfAssessForm.tu_danh_gia,
        selfAssessForm.diem_tu_danh_gia
      );
      addNotification('success', 'Tự đánh giá thành công');
      setSelfAssessModal({ isOpen: false, item: null });
      loadData();
    } catch (error) {
      addNotification('error', 'Có lỗi xảy ra');
    } finally {
      setSubmitting(false);
    }
  };

  const handleEvaluate = async () => {
    if (!evaluateModal.item) return;

    setSubmitting(true);
    try {
      await nhiemVuApi.danhGia(
        evaluateModal.item.id,
        evaluateForm.danh_gia_lanh_dao,
        evaluateForm.diem_lanh_dao
      );
      addNotification('success', 'Đánh giá thành công');
      setEvaluateModal({ isOpen: false, item: null });
      loadData();
    } catch (error) {
      addNotification('error', 'Có lỗi xảy ra');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Bạn có chắc muốn hủy nhiệm vụ này?')) return;
    try {
      await nhiemVuApi.delete(id);
      addNotification('success', 'Đã hủy nhiệm vụ');
      loadData();
    } catch (error) {
      addNotification('error', 'Không thể hủy nhiệm vụ');
    }
  };

  const daGiaoColumns = [
    {
      key: 'nguoi_nhan',
      title: 'Người nhận',
      render: (item: NhiemVu) => item.nguoi_nhan?.ho_ten || '',
    },
    {
      key: 'noi_dung',
      title: 'Nội dung',
      render: (item: NhiemVu) => (
        <span className="max-w-xs truncate block">{item.noi_dung}</span>
      ),
    },
    {
      key: 'han_hoan_thanh',
      title: 'Hạn',
      render: (item: NhiemVu) => item.han_hoan_thanh ? formatDate(item.han_hoan_thanh) : '-',
    },
    {
      key: 'trang_thai',
      title: 'Trạng thái',
      render: (item: NhiemVu) => (
        <Badge className={getTrangThaiNhiemVuColor(item.trang_thai)}>
          {getTrangThaiNhiemVuLabel(item.trang_thai)}
        </Badge>
      ),
    },
    {
      key: 'diem',
      title: 'Điểm',
      render: (item: NhiemVu) => (
        <div className="text-sm">
          {item.diem_tu_danh_gia && <span className="text-gray-500">TĐG: {item.diem_tu_danh_gia}</span>}
          {item.diem_lanh_dao && <span className="ml-2 text-blue-600">LĐ: {item.diem_lanh_dao}</span>}
        </div>
      ),
    },
    {
      key: 'actions',
      title: '',
      render: (item: NhiemVu) => (
        <div className="flex gap-2">
          {item.trang_thai === 'HOAN_THANH' && (
            <button
              onClick={() => {
                setEvaluateModal({ isOpen: true, item });
                setEvaluateForm({ danh_gia_lanh_dao: '', diem_lanh_dao: 8 });
              }}
              className="text-blue-600 hover:text-blue-800"
            >
              Đánh giá
            </button>
          )}
          {item.trang_thai === 'MOI_GIAO' && (
            <button
              onClick={() => handleDelete(item.id)}
              className="text-red-600 hover:text-red-800"
            >
              Hủy
            </button>
          )}
        </div>
      ),
    },
  ];

  const duocGiaoColumns = [
    {
      key: 'nguoi_giao',
      title: 'Người giao',
      render: (item: NhiemVu) => item.nguoi_giao?.ho_ten || '',
    },
    {
      key: 'noi_dung',
      title: 'Nội dung',
      render: (item: NhiemVu) => (
        <span className="max-w-xs truncate block">{item.noi_dung}</span>
      ),
    },
    {
      key: 'han_hoan_thanh',
      title: 'Hạn',
      render: (item: NhiemVu) => item.han_hoan_thanh ? formatDate(item.han_hoan_thanh) : '-',
    },
    {
      key: 'trang_thai',
      title: 'Trạng thái',
      render: (item: NhiemVu) => (
        <Badge className={getTrangThaiNhiemVuColor(item.trang_thai)}>
          {getTrangThaiNhiemVuLabel(item.trang_thai)}
        </Badge>
      ),
    },
    {
      key: 'diem',
      title: 'Điểm',
      render: (item: NhiemVu) => (
        <div className="text-sm">
          {item.diem_tu_danh_gia && <span className="text-gray-500">TĐG: {item.diem_tu_danh_gia}</span>}
          {item.diem_lanh_dao && <span className="ml-2 text-blue-600">LĐ: {item.diem_lanh_dao}</span>}
        </div>
      ),
    },
    {
      key: 'actions',
      title: '',
      render: (item: NhiemVu) => (
        <div className="flex gap-2">
          {(item.trang_thai === 'MOI_GIAO' || item.trang_thai === 'DANG_THUC_HIEN') && (
            <button
              onClick={() => {
                setSelfAssessModal({ isOpen: true, item });
                setSelfAssessForm({ tu_danh_gia: '', diem_tu_danh_gia: 8 });
              }}
              className="text-green-600 hover:text-green-800"
            >
              Tự đánh giá
            </button>
          )}
        </div>
      ),
    },
  ];

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Spinner size="lg" />
      </div>
    );
  }

  const canAssignTasks = user?.co_the_phe_duyet || (user?.cap_lanh_dao && user.cap_lanh_dao <= 4);

  const tabs = [
    {
      key: 'duoc_giao',
      label: `Được giao (${duocGiaoList.length})`,
      content: duocGiaoList.length === 0 ? (
        <EmptyState title="Chưa có nhiệm vụ được giao" />
      ) : (
        <Table columns={duocGiaoColumns} data={duocGiaoList} rowKey={(item) => item.id} />
      ),
    },
    ...(canAssignTasks
      ? [
          {
            key: 'da_giao',
            label: `Đã giao (${daGiaoList.length})`,
            content: daGiaoList.length === 0 ? (
              <EmptyState
                title="Chưa giao nhiệm vụ nào"
                action={<Button onClick={() => setIsCreateModalOpen(true)}>+ Giao nhiệm vụ</Button>}
              />
            ) : (
              <Table columns={daGiaoColumns} data={daGiaoList} rowKey={(item) => item.id} />
            ),
          },
        ]
      : []),
  ];

  return (
    <div className="space-y-6">
      <Card
        title={`Nhiệm vụ - Tháng ${currentMonth}/${currentYear}`}
        actions={
          canAssignTasks && (
            <Button onClick={() => setIsCreateModalOpen(true)}>+ Giao nhiệm vụ</Button>
          )
        }
      >
        <Tabs tabs={tabs} />
      </Card>

      {/* Create Task Modal */}
      <Modal isOpen={isCreateModalOpen} onClose={() => setIsCreateModalOpen(false)} title="Giao nhiệm vụ mới">
        <form onSubmit={handleCreateTask} className="space-y-4">
          <Select
            label="Người nhận *"
            value={createForm.nguoi_nhan_id}
            onChange={(e) => setCreateForm({ ...createForm, nguoi_nhan_id: Number(e.target.value) })}
            options={[
              { value: 0, label: '-- Chọn người nhận --' },
              ...nguoiCoTheGiao.map((n) => ({
                value: n.id,
                label: `${n.ho_ten} - ${n.ma_cong_chuc}`,
              })),
            ]}
          />
          <Textarea
            label="Nội dung nhiệm vụ *"
            value={createForm.noi_dung}
            onChange={(e) => setCreateForm({ ...createForm, noi_dung: e.target.value })}
            rows={4}
            placeholder="Mô tả chi tiết nhiệm vụ..."
          />
          <Input
            label="Hạn hoàn thành"
            type="date"
            value={createForm.han_hoan_thanh}
            onChange={(e) => setCreateForm({ ...createForm, han_hoan_thanh: e.target.value })}
          />
          <div className="flex justify-end gap-2 pt-4">
            <Button type="button" variant="secondary" onClick={() => setIsCreateModalOpen(false)}>
              Hủy
            </Button>
            <Button type="submit" loading={submitting}>
              Giao nhiệm vụ
            </Button>
          </div>
        </form>
      </Modal>

      {/* Self Assessment Modal */}
      <Modal
        isOpen={selfAssessModal.isOpen}
        onClose={() => setSelfAssessModal({ isOpen: false, item: null })}
        title="Tự đánh giá nhiệm vụ"
      >
        {selfAssessModal.item && (
          <div className="space-y-4">
            <div className="bg-gray-50 p-4 rounded-lg">
              <p className="text-sm text-gray-600">{selfAssessModal.item.noi_dung}</p>
            </div>
            <Textarea
              label="Báo cáo kết quả *"
              value={selfAssessForm.tu_danh_gia}
              onChange={(e) => setSelfAssessForm({ ...selfAssessForm, tu_danh_gia: e.target.value })}
              rows={4}
              placeholder="Mô tả kết quả thực hiện nhiệm vụ..."
            />
            <Select
              label="Điểm tự đánh giá *"
              value={selfAssessForm.diem_tu_danh_gia}
              onChange={(e) => setSelfAssessForm({ ...selfAssessForm, diem_tu_danh_gia: Number(e.target.value) })}
              options={[10, 9, 8, 7, 6, 5, 4, 3, 2, 1].map((d) => ({
                value: d,
                label: `${d} điểm`,
              }))}
            />
            <div className="flex justify-end gap-2 pt-4">
              <Button variant="secondary" onClick={() => setSelfAssessModal({ isOpen: false, item: null })}>
                Hủy
              </Button>
              <Button onClick={handleSelfAssess} loading={submitting} disabled={!selfAssessForm.tu_danh_gia}>
                Gửi đánh giá
              </Button>
            </div>
          </div>
        )}
      </Modal>

      {/* Leader Evaluation Modal */}
      <Modal
        isOpen={evaluateModal.isOpen}
        onClose={() => setEvaluateModal({ isOpen: false, item: null })}
        title="Đánh giá nhiệm vụ"
      >
        {evaluateModal.item && (
          <div className="space-y-4">
            <div className="bg-gray-50 p-4 rounded-lg space-y-2">
              <p className="font-medium">{evaluateModal.item.nguoi_nhan?.ho_ten}</p>
              <p className="text-sm text-gray-600">{evaluateModal.item.noi_dung}</p>
              {evaluateModal.item.tu_danh_gia && (
                <div className="mt-2 pt-2 border-t">
                  <p className="text-sm text-gray-500">Tự đánh giá: {evaluateModal.item.tu_danh_gia}</p>
                  <p className="text-sm text-gray-500">Điểm TĐG: {evaluateModal.item.diem_tu_danh_gia}</p>
                </div>
              )}
            </div>
            <Textarea
              label="Nhận xét của lãnh đạo"
              value={evaluateForm.danh_gia_lanh_dao}
              onChange={(e) => setEvaluateForm({ ...evaluateForm, danh_gia_lanh_dao: e.target.value })}
              rows={3}
              placeholder="Nhận xét về kết quả thực hiện..."
            />
            <Select
              label="Điểm đánh giá *"
              value={evaluateForm.diem_lanh_dao}
              onChange={(e) => setEvaluateForm({ ...evaluateForm, diem_lanh_dao: Number(e.target.value) })}
              options={[10, 9, 8, 7, 6, 5, 4, 3, 2, 1].map((d) => ({
                value: d,
                label: `${d} điểm`,
              }))}
            />
            <div className="flex justify-end gap-2 pt-4">
              <Button variant="secondary" onClick={() => setEvaluateModal({ isOpen: false, item: null })}>
                Hủy
              </Button>
              <Button onClick={handleEvaluate} loading={submitting}>
                Xác nhận đánh giá
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
};
