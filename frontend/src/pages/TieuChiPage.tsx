import { useState, useEffect } from 'react'
import { api } from '../api'
import { Button, Card, Modal, Input, Alert, LoadingSpinner } from '../components/ui'

interface TieuChiChung {
  id: number
  thang: number
  nam: number
  diem_cham_cong: number
  diem_ky_luat: number
  diem_phoi_hop: number
  tong_diem: number
  ghi_chu: string | null
  created_at: string
}

// Sửa thành Named Export
export function TieuChiPage() {
  const [tieuChis, setTieuChis] = useState<TieuChiChung[]>([])
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  
  const [showModal, setShowModal] = useState(false)
  const [editingId, setEditingId] = useState<number | null>(null)
  
  const currentMonth = new Date().getMonth() + 1
  const currentYear = new Date().getFullYear()
  
  const [form, setForm] = useState({
    thang: currentMonth,
    nam: currentYear,
    diem_cham_cong: '10',
    diem_ky_luat: '10',
    diem_phoi_hop: '10',
    ghi_chu: '',
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      setLoading(true)
      const res = await api.tieuChi.getMyTieuChi()
      // API có thể trả về null hoặc object, bọc vào mảng nếu cần
      if (res) {
          setTieuChis([res]) // Giả sử API trả về 1 object cho tháng hiện tại
      } else {
          setTieuChis([])
      }
    } catch (err: any) {
      setError(err.message || 'Lỗi tải dữ liệu')
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setSuccess('')

    const diemChamCong = Number(form.diem_cham_cong)
    const diemKyLuat = Number(form.diem_ky_luat)
    const diemPhoiHop = Number(form.diem_phoi_hop)

    if (diemChamCong < 0 || diemChamCong > 10) {
      setError('Điểm chấm công phải từ 0-10')
      return
    }
    if (diemKyLuat < 0 || diemKyLuat > 10) {
      setError('Điểm kỷ luật phải từ 0-10')
      return
    }
    if (diemPhoiHop < 0 || diemPhoiHop > 10) {
      setError('Điểm phối hợp phải từ 0-10')
      return
    }

    try {
      setSubmitting(true)
      const payload = {
        thang: form.thang,
        nam: form.nam,
        diem_cham_cong: diemChamCong,
        diem_ky_luat: diemKyLuat,
        diem_phoi_hop: diemPhoiHop,
        ghi_chu: form.ghi_chu || '',
      }

      if (editingId) {
        await api.tieuChi.update(editingId, payload)
        setSuccess('Cập nhật tiêu chí thành công')
      } else {
        await api.tieuChi.create(payload)
        setSuccess('Tạo tiêu chí thành công')
      }
      
      setShowModal(false)
      resetForm()
      loadData()
    } catch (err: any) {
      setError(err.message || 'Lỗi lưu tiêu chí')
    } finally {
      setSubmitting(false)
    }
  }

  const resetForm = () => {
    setForm({
      thang: currentMonth,
      nam: currentYear,
      diem_cham_cong: '10',
      diem_ky_luat: '10',
      diem_phoi_hop: '10',
      ghi_chu: '',
    })
    setEditingId(null)
  }

  const handleEdit = (tc: TieuChiChung) => {
    setForm({
      thang: tc.thang,
      nam: tc.nam,
      diem_cham_cong: String(tc.diem_cham_cong),
      diem_ky_luat: String(tc.diem_ky_luat),
      diem_phoi_hop: String(tc.diem_phoi_hop),
      ghi_chu: tc.ghi_chu || '',
    })
    setEditingId(tc.id)
    setShowModal(true)
  }

  // Check if current month already has entry
  const currentMonthEntry = tieuChis.find(tc => tc.thang === currentMonth && tc.nam === currentYear)

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Tiêu chí chung</h1>
          <p className="text-gray-600 mt-1">Chấm điểm chấm công, kỷ luật, phối hợp (tối đa 30 điểm/tháng)</p>
        </div>
        {!currentMonthEntry && (
          <Button onClick={() => { resetForm(); setShowModal(true); }} variant="primary">
            + Khai báo tháng {currentMonth}/{currentYear}
          </Button>
        )}
      </div>

      {error && <Alert type="error" onClose={() => setError('')}>{error}</Alert>}
      {success && <Alert type="success" onClose={() => setSuccess('')}>{success}</Alert>}

      {/* Info Card */}
      <Card className="p-4 bg-blue-50 border-blue-200">
        <h3 className="font-medium text-blue-900 mb-2">Hướng dẫn chấm điểm</h3>
        <ul className="text-sm text-blue-800 space-y-1">
          <li>• <strong>Điểm chấm công (0-10):</strong> Đi làm đúng giờ, không nghỉ không phép</li>
          <li>• <strong>Điểm kỷ luật (0-10):</strong> Chấp hành nội quy, quy chế cơ quan</li>
          <li>• <strong>Điểm phối hợp (0-10):</strong> Phối hợp tốt với đồng nghiệp</li>
        </ul>
      </Card>

      {/* Table */}
      <Card>
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Tháng/Năm</th>
                <th className="text-center">Chấm công</th>
                <th className="text-center">Kỷ luật</th>
                <th className="text-center">Phối hợp</th>
                <th className="text-center">Tổng điểm</th>
                <th>Ghi chú</th>
                <th className="text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {tieuChis.length === 0 ? (
                <tr>
                  <td colSpan={7} className="text-center py-8 text-gray-500">
                    Chưa có tiêu chí nào
                  </td>
                </tr>
              ) : (
                tieuChis.map(tc => (
                  <tr key={tc.id}>
                    <td className="font-medium">{tc.thang}/{tc.nam}</td>
                    <td className="text-center">{tc.diem_cham_cong}</td>
                    <td className="text-center">{tc.diem_ky_luat}</td>
                    <td className="text-center">{tc.diem_phoi_hop}</td>
                    <td className="text-center font-bold text-blue-600">{tc.tong_diem}</td>
                    <td className="text-gray-500">{tc.ghi_chu || '-'}</td>
                    <td className="text-center">
                      <Button size="sm" variant="secondary" onClick={() => handleEdit(tc)}>
                        Sửa
                      </Button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </Card>

      {/* Modal */}
      <Modal isOpen={showModal} onClose={() => setShowModal(false)} title={editingId ? 'Sửa tiêu chí' : 'Khai báo tiêu chí'}>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Tháng</label>
              <Input
                type="number"
                min="1"
                max="12"
                value={form.thang}
                onChange={(e) => setForm(prev => ({ ...prev, thang: Number(e.target.value) }))}
                disabled={!!editingId}
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Năm</label>
              <Input
                type="number"
                min="2024"
                max="2030"
                value={form.nam}
                onChange={(e) => setForm(prev => ({ ...prev, nam: Number(e.target.value) }))}
                disabled={!!editingId}
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Điểm chấm công (0-10)</label>
            <Input
              type="number"
              min="0"
              max="10"
              step="0.5"
              value={form.diem_cham_cong}
              onChange={(e) => setForm(prev => ({ ...prev, diem_cham_cong: e.target.value }))}
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Điểm kỷ luật (0-10)</label>
            <Input
              type="number"
              min="0"
              max="10"
              step="0.5"
              value={form.diem_ky_luat}
              onChange={(e) => setForm(prev => ({ ...prev, diem_ky_luat: e.target.value }))}
              required
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Điểm phối hợp (0-10)</label>
            <Input
              type="number"
              min="0"
              max="10"
              step="0.5"
              value={form.diem_phoi_hop}
              onChange={(e) => setForm(prev => ({ ...prev, diem_phoi_hop: e.target.value }))}
              required
            />
          </div>

          <div className="bg-gray-50 p-3 rounded-lg">
            <span className="text-sm text-gray-700">
              Tổng điểm: <strong className="text-blue-600">
                {(Number(form.diem_cham_cong) + Number(form.diem_ky_luat) + Number(form.diem_phoi_hop)).toFixed(1)}
              </strong> / 30
            </span>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Ghi chú</label>
            <Input
              value={form.ghi_chu}
              onChange={(e) => setForm(prev => ({ ...prev, ghi_chu: e.target.value }))}
              placeholder="Ghi chú (nếu có)"
            />
          </div>

          <div className="flex gap-2 justify-end pt-4">
            <Button type="button" variant="secondary" onClick={() => setShowModal(false)}>
              Hủy
            </Button>
            <Button type="submit" variant="primary" disabled={submitting}>
              {submitting ? 'Đang lưu...' : (editingId ? 'Cập nhật' : 'Tạo mới')}
            </Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}