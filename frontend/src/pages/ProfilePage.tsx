import { useState } from 'react'
import { useAuthStore } from '../store'
import { api } from '../api'
import { Button, Card, Input, Alert } from '../components/ui'

export default function ProfilePage() {
  const { user, setUser } = useAuthStore()
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [submitting, setSubmitting] = useState(false)

  const [passwordForm, setPasswordForm] = useState({
    mat_khau_cu: '',
    mat_khau_moi: '',
    xac_nhan_mat_khau: '',
  })

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setSuccess('')

    if (passwordForm.mat_khau_moi !== passwordForm.xac_nhan_mat_khau) {
      setError('Mật khẩu mới không khớp')
      return
    }

    if (passwordForm.mat_khau_moi.length < 6) {
      setError('Mật khẩu mới phải có ít nhất 6 ký tự')
      return
    }

    try {
      setSubmitting(true)
      await api.post('/auth/change-password', {
        mat_khau_cu: passwordForm.mat_khau_cu,
        mat_khau_moi: passwordForm.mat_khau_moi,
      })
      setSuccess('Đổi mật khẩu thành công')
      setPasswordForm({
        mat_khau_cu: '',
        mat_khau_moi: '',
        xac_nhan_mat_khau: '',
      })
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Lỗi đổi mật khẩu')
    } finally {
      setSubmitting(false)
    }
  }

  const capLanhDaoLabels: Record<number, string> = {
    1: 'Chi cục trưởng',
    2: 'Phó Chi cục trưởng',
    3: 'Trưởng phòng/Đội trưởng/Chánh VP',
    4: 'Phó phòng/Phó đội/Phó VP',
    5: 'Công chức',
    6: 'Hợp đồng',
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <h1 className="text-2xl font-bold text-gray-900">Thông tin cá nhân</h1>

      {error && <Alert type="error" onClose={() => setError('')}>{error}</Alert>}
      {success && <Alert type="success" onClose={() => setSuccess('')}>{success}</Alert>}

      {/* User Info Card */}
      <Card className="p-6">
        <h2 className="text-lg font-semibold mb-4">Thông tin tài khoản</h2>
        <div className="grid md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-500">Mã công chức</label>
            <p className="mt-1 text-lg font-mono">{user?.ma_cong_chuc}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500">Họ và tên</label>
            <p className="mt-1 text-lg font-medium">{user?.ho_ten}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500">Năm sinh</label>
            <p className="mt-1">{user?.nam_sinh || '-'}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500">Đơn vị</label>
            <p className="mt-1">{user?.don_vi_ten}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500">Chức vụ</label>
            <p className="mt-1">{user?.chuc_vu_ten}</p>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-500">Cấp lãnh đạo</label>
            <p className="mt-1">
              Cấp {user?.cap_lanh_dao} - {capLanhDaoLabels[user?.cap_lanh_dao || 5]}
            </p>
          </div>
        </div>

        {/* Role badges */}
        <div className="mt-4 pt-4 border-t flex gap-2">
          {user?.co_the_phe_duyet && (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800">
              ✓ Có quyền phê duyệt
            </span>
          )}
          {user?.la_tccb && (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800">
              ✓ TCCB
            </span>
          )}
          {user?.la_admin && (
            <span className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-purple-100 text-purple-800">
              ✓ Admin
            </span>
          )}
        </div>
      </Card>

      {/* Change Password Card */}
      <Card className="p-6">
        <h2 className="text-lg font-semibold mb-4">Đổi mật khẩu</h2>
        <form onSubmit={handleChangePassword} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu hiện tại</label>
            <Input
              type="password"
              value={passwordForm.mat_khau_cu}
              onChange={(e) => setPasswordForm(prev => ({ ...prev, mat_khau_cu: e.target.value }))}
              placeholder="Nhập mật khẩu hiện tại"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Mật khẩu mới</label>
            <Input
              type="password"
              value={passwordForm.mat_khau_moi}
              onChange={(e) => setPasswordForm(prev => ({ ...prev, mat_khau_moi: e.target.value }))}
              placeholder="Nhập mật khẩu mới (ít nhất 6 ký tự)"
              required
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Xác nhận mật khẩu mới</label>
            <Input
              type="password"
              value={passwordForm.xac_nhan_mat_khau}
              onChange={(e) => setPasswordForm(prev => ({ ...prev, xac_nhan_mat_khau: e.target.value }))}
              placeholder="Nhập lại mật khẩu mới"
              required
            />
          </div>
          <Button type="submit" variant="primary" disabled={submitting}>
            {submitting ? 'Đang xử lý...' : 'Đổi mật khẩu'}
          </Button>
        </form>
      </Card>

      {/* Help Card */}
      <Card className="p-6 bg-blue-50 border-blue-200">
        <h2 className="text-lg font-semibold text-blue-900 mb-2">Hướng dẫn sử dụng</h2>
        <ul className="text-sm text-blue-800 space-y-2">
          <li>• <strong>Kê khai:</strong> Đăng ký sản phẩm công việc hàng ngày</li>
          <li>• <strong>Phê duyệt:</strong> Duyệt kê khai của nhân viên (nếu có quyền)</li>
          <li>• <strong>Nhiệm vụ:</strong> Xem và thực hiện nhiệm vụ được giao</li>
          <li>• <strong>Tiêu chí:</strong> Chấm điểm tiêu chí chung hàng tháng</li>
          <li>• <strong>Nghỉ phép:</strong> Đăng ký nghỉ phép</li>
          <li>• <strong>KPI:</strong> Xem kết quả KPI cá nhân</li>
        </ul>
      </Card>
    </div>
  )
}
