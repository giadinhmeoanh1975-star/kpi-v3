import { useState, useEffect } from 'react'
import { useAuthStore } from '../store'
import { api } from '../api'
// @ts-ignore
import { Button, Card, Modal, Select, Input, Badge, Alert, LoadingSpinner } from '../components/ui'

interface NghiPhep {
  id: number
  ngay_bat_dau: string
  ngay_ket_thuc: string
  so_ngay: number
  loai_nghi: string
  ly_do: string
  trang_thai: string
  nguoi_duyet_id: number | null
  nguoi_duyet_ten: string | null
  ly_do_tu_choi: string | null
  created_at: string
}

const LOAI_NGHI = {
  PHEP_NAM: 'Nghỉ phép năm',
  NGHI_OM: 'Nghỉ ốm',
  NGHI_VIEC_RIENG: 'Nghỉ việc riêng',
  NGHI_KHONG_LUONG: 'Nghỉ không lương',
  NGHI_LE: 'Nghỉ lễ',
  NGHI_BU: 'Nghỉ bù',
}

const TRANG_THAI_LABELS: Record<string, { label: string; color: string }> = {
  CHO_DUYET: { label: 'Chờ duyệt', color: 'warning' },
  DA_DUYET: { label: 'Đã duyệt', color: 'success' },
  TU_CHOI: { label: 'Từ chối', color: 'danger' },
  HUY: { label: 'Đã hủy', color: 'gray' },
}

// Sửa thành Named Export
export function NghiPhepPage() {
  const { user } = useAuthStore()
  const [nghiPheps, setNghiPheps] = useState<NghiPhep[]>([])
  const [pendingApprovals, setPendingApprovals] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  
  const [showModal, setShowModal] = useState(false)
  const [form, setForm] = useState({
    ngay_bat_dau: '',
    ngay_ket_thuc: '',
    loai_nghi: 'PHEP_NAM',
    ly_do: '',
  })

  const [activeTab, setActiveTab] = useState<'my' | 'approve'>('my')

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setLoading(true)
      const myRes = await api.nghiPhep.getMyNghiPhep()
      setNghiPheps(myRes)

      // Load pending approvals if user can approve
      if (user?.la_tccb || (user?.cap_lanh_dao && user.cap_lanh_dao <= 3)) {
        const pendingRes = await api.nghiPhep.getChoDuyet()
        setPendingApprovals(pendingRes)
      }
    } catch (err: any) {
      setError(err.message || 'Lỗi tải dữ liệu')
    } finally {
      setLoading(false)
    }
  }

  const calculateDays = (start: string, end: string) => {
    if (!start || !end) return 0
    const startDate = new Date(start)
    const endDate = new Date(end)
    const diffTime = Math.abs(endDate.getTime() - startDate.getTime())
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24)) + 1
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setSuccess('')

    if (!form.ngay_bat_dau || !form.ngay_ket_thuc) {
      setError('Vui lòng chọn ngày nghỉ')
      return
    }

    if (new Date(form.ngay_ket_thuc) < new Date(form.ngay_bat_dau)) {
      setError('Ngày kết thúc phải sau ngày bắt đầu')
      return
    }

    if (!form.ly_do.trim()) {
      setError('Vui lòng nhập lý do nghỉ')
      return
    }

    try {
      setSubmitting(true)
      await api.nghiPhep.create({
        ngay_bat_dau: form.ngay_bat_dau,
        ngay_ket_thuc: form.ngay_ket_thuc,
        loai_nghi: form.loai_nghi,
        ly_do: form.ly_do,
      })
      setSuccess('Đăng ký nghỉ phép thành công')
      setShowModal(false)
      resetForm()
      loadData()
    } catch (err: any) {
      setError(err.message || 'Lỗi đăng ký nghỉ phép')
    } finally {
      setSubmitting(false)
    }
  }

  const resetForm = () => {
    setForm({
      ngay_bat_dau: '',
      ngay_ket_thuc: '',
      loai_nghi: 'PHEP_NAM',
      ly_do: '',
    })
  }

  const handleCancel = async (id: number) => {
    if (!confirm('Bạn có chắc muốn hủy đơn nghỉ phép này?')) return
    try {
      await api.nghiPhep.delete(id)
      setSuccess('Đã hủy đơn nghỉ phép')
      loadData()
    } catch (err: any) {
      setError(err.message || 'Lỗi hủy đơn')
    }
  }

  const handleApprove = async (id: number, approved: boolean, lyDo?: string) => {
    try {
      await api.nghiPhep.approve(id, approved ? 'duyet' : 'tu_choi', lyDo)
      setSuccess(approved ? 'Đã duyệt đơn nghỉ phép' : 'Đã từ chối đơn nghỉ phép')
      loadData()
    } catch (err: any) {
      setError(err.message || 'Lỗi duyệt đơn')
    }
  }

  const canApprove = user?.la_tccb || (user?.cap_lanh_dao && user.cap_lanh_dao <= 3)

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Quản lý nghỉ phép</h1>
        <Button onClick={() => { resetForm(); setShowModal(true); }} variant="primary">
          + Đăng ký nghỉ
        </Button>
      </div>

      {error && <Alert type="error" onClose={() => setError('')}>{error}</Alert>}
      {success && <Alert type="success" onClose={() => setSuccess('')}>{success}</Alert>}

      {/* Tabs */}
      {canApprove && (
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex space-x-8">
            <button
              onClick={() => setActiveTab('my')}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'my'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Đơn của tôi ({nghiPheps.length})
            </button>
            <button
              onClick={() => setActiveTab('approve')}
              className={`py-2 px-1 border-b-2 font-medium text-sm ${
                activeTab === 'approve'
                  ? 'border-blue-500 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Chờ duyệt ({pendingApprovals.length})
            </button>
          </nav>
        </div>
      )}

      {/* My Leave Requests */}
      {activeTab === 'my' && (
        <Card>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Từ ngày</th>
                  <th>Đến ngày</th>
                  <th className="text-center">Số ngày</th>
                  <th>Loại nghỉ</th>
                  <th>Lý do</th>
                  <th>Trạng thái</th>
                  <th>Người duyệt</th>
                  <th className="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {nghiPheps.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="text-center py-8 text-gray-500">
                      Chưa có đơn nghỉ phép nào
                    </td>
                  </tr>
                ) : (
                  nghiPheps.map(np => (
                    <tr key={np.id}>
                      <td>{new Date(np.ngay_bat_dau).toLocaleDateString('vi-VN')}</td>
                      <td>{new Date(np.ngay_ket_thuc).toLocaleDateString('vi-VN')}</td>
                      <td className="text-center">{np.so_ngay}</td>
                      <td>{LOAI_NGHI[np.loai_nghi as keyof typeof LOAI_NGHI]}</td>
                      <td className="max-w-xs truncate">{np.ly_do}</td>
                      <td>
                         {/* @ts-ignore */}
                        <Badge color={TRANG_THAI_LABELS[np.trang_thai]?.color || 'gray'}>
                          {TRANG_THAI_LABELS[np.trang_thai]?.label || np.trang_thai}
                        </Badge>
                        {np.ly_do_tu_choi && (
                          <div className="text-xs text-red-600 mt-1">{np.ly_do_tu_choi}</div>
                        )}
                      </td>
                      <td>{np.nguoi_duyet_ten || '-'}</td>
                      <td className="text-center">
                        {np.trang_thai === 'CHO_DUYET' && (
                          <Button size="sm" variant="danger" onClick={() => handleCancel(np.id)}>
                            Hủy
                          </Button>
                        )}
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Pending Approvals */}
      {activeTab === 'approve' && canApprove && (
        <Card>
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Người đăng ký</th>
                  <th>Đơn vị</th>
                  <th>Từ ngày</th>
                  <th>Đến ngày</th>
                  <th className="text-center">Số ngày</th>
                  <th>Loại nghỉ</th>
                  <th>Lý do</th>
                  <th className="text-center">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {pendingApprovals.length === 0 ? (
                  <tr>
                    <td colSpan={8} className="text-center py-8 text-gray-500">
                      Không có đơn nào chờ duyệt
                    </td>
                  </tr>
                ) : (
                  pendingApprovals.map(np => (
                    <tr key={np.id}>
                      <td className="font-medium">{np.nguoi_dung_ten}</td>
                      <td>{np.don_vi_ten}</td>
                      <td>{new Date(np.ngay_bat_dau).toLocaleDateString('vi-VN')}</td>
                      <td>{new Date(np.ngay_ket_thuc).toLocaleDateString('vi-VN')}</td>
                      <td className="text-center">{np.so_ngay}</td>
                      <td>{LOAI_NGHI[np.loai_nghi as keyof typeof LOAI_NGHI]}</td>
                      <td className="max-w-xs truncate">{np.ly_do}</td>
                      <td className="text-center">
                        <div className="flex gap-1 justify-center">
                          <Button size="sm" variant="success" onClick={() => handleApprove(np.id, true)}>
                            Duyệt
                          </Button>
                          <Button size="sm" variant="danger" onClick={() => {
                            const lyDo = prompt('Lý do từ chối:')
                            if (lyDo) handleApprove(np.id, false, lyDo)
                          }}>
                            Từ chối
                          </Button>
                        </div>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Modal */}
      <Modal isOpen={showModal} onClose={() => setShowModal(false)} title="Đăng ký nghỉ phép">
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Từ ngày *</label>
              <Input
                type="date"
                value={form.ngay_bat_dau}
                onChange={(e) => setForm(prev => ({ ...prev, ngay_bat_dau: e.target.value }))}
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Đến ngày *</label>
              <Input
                type="date"
                value={form.ngay_ket_thuc}
                onChange={(e) => setForm(prev => ({ ...prev, ngay_ket_thuc: e.target.value }))}
                required
              />
            </div>
          </div>

          {form.ngay_bat_dau && form.ngay_ket_thuc && (
            <div className="bg-blue-50 p-3 rounded-lg">
              <span className="text-sm text-blue-700">
                Số ngày nghỉ: <strong>{calculateDays(form.ngay_bat_dau, form.ngay_ket_thuc)}</strong> ngày
              </span>
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Loại nghỉ *</label>
             {/* @ts-ignore */}
            <Select
              value={form.loai_nghi}
              onChange={(e) => setForm(prev => ({ ...prev, loai_nghi: e.target.value }))}
            >
              {Object.entries(LOAI_NGHI).map(([key, label]) => (
                <option key={key} value={key}>{label}</option>
              ))}
            </Select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Lý do *</label>
            <textarea
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              rows={3}
              value={form.ly_do}
              onChange={(e) => setForm(prev => ({ ...prev, ly_do: e.target.value }))}
              placeholder="Nhập lý do nghỉ phép"
              required
            />
          </div>

          <div className="flex gap-2 justify-end pt-4">
            <Button type="button" variant="secondary" onClick={() => setShowModal(false)}>
              Hủy
            </Button>
            <Button type="submit" variant="primary" disabled={submitting}>
              {submitting ? 'Đang gửi...' : 'Gửi đơn'}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}