import { useState, useEffect } from 'react'
import { Routes, Route, Link, useLocation } from 'react-router-dom'
import { useAuthStore } from '../store'
import { api } from '../api'
import { Button, Card, Modal, Select, Input, Badge, Alert, LoadingSpinner } from '../components/ui'

// Admin Dashboard
function AdminDashboard() {
  const [stats, setStats] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      const res = await api.get('/admin/thong-ke')
      setStats(res.data)
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold">Tổng quan hệ thống</h2>
      
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card className="p-4 text-center">
          <div className="text-3xl font-bold text-blue-600">{stats?.tong_nguoi_dung || 0}</div>
          <div className="text-sm text-gray-500">Tổng người dùng</div>
        </Card>
        <Card className="p-4 text-center">
          <div className="text-3xl font-bold text-green-600">{stats?.tong_ke_khai || 0}</div>
          <div className="text-sm text-gray-500">Tổng kê khai</div>
        </Card>
        <Card className="p-4 text-center">
          <div className="text-3xl font-bold text-yellow-600">{stats?.ke_khai_cho_duyet || 0}</div>
          <div className="text-sm text-gray-500">Chờ duyệt</div>
        </Card>
        <Card className="p-4 text-center">
          <div className="text-3xl font-bold text-purple-600">{stats?.tong_don_vi || 0}</div>
          <div className="text-sm text-gray-500">Đơn vị</div>
        </Card>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <Card className="p-4">
          <h3 className="font-medium mb-4">Kê khai theo đơn vị</h3>
          {stats?.ke_khai_theo_don_vi?.map((item: any) => (
            <div key={item.don_vi} className="flex justify-between py-2 border-b last:border-0">
              <span>{item.don_vi}</span>
              <span className="font-medium">{item.so_luong}</span>
            </div>
          ))}
        </Card>

        <Card className="p-4">
          <h3 className="font-medium mb-4">Hoạt động gần đây</h3>
          {stats?.hoat_dong_gan_day?.map((item: any, i: number) => (
            <div key={i} className="flex justify-between py-2 border-b last:border-0">
              <span className="text-sm">{item.mo_ta}</span>
              <span className="text-xs text-gray-500">{item.thoi_gian}</span>
            </div>
          ))}
        </Card>
      </div>
    </div>
  )
}

// User Management
function UserManagement() {
  const [users, setUsers] = useState<any[]>([])
  const [donVis, setDonVis] = useState<any[]>([])
  const [chucVus, setChucVus] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  
  const [filters, setFilters] = useState({ don_vi_id: '', chuc_vu_id: '', search: '' })
  const [showModal, setShowModal] = useState(false)
  const [editingUser, setEditingUser] = useState<any>(null)

  useEffect(() => {
    loadData()
  }, [filters.don_vi_id, filters.chuc_vu_id])

  const loadData = async () => {
    try {
      setLoading(true)
      const [usersRes, donViRes, chucVuRes] = await Promise.all([
        api.get('/admin/nguoi-dung', { params: filters }),
        api.get('/danh-muc/don-vi'),
        api.get('/danh-muc/chuc-vu'),
      ])
      setUsers(usersRes.data)
      setDonVis(donViRes.data)
      setChucVus(chucVuRes.data)
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Lỗi tải dữ liệu')
    } finally {
      setLoading(false)
    }
  }

  const handleResetPassword = async (userId: number) => {
    if (!confirm('Reset mật khẩu về 123456?')) return
    try {
      await api.post(`/admin/nguoi-dung/${userId}/reset-password`)
      setSuccess('Đã reset mật khẩu thành công')
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Lỗi reset mật khẩu')
    }
  }

  const handleToggleActive = async (userId: number, active: boolean) => {
    try {
      await api.put(`/admin/nguoi-dung/${userId}`, { dang_hoat_dong: active })
      setSuccess(active ? 'Đã kích hoạt tài khoản' : 'Đã vô hiệu hóa tài khoản')
      loadData()
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Lỗi cập nhật')
    }
  }

  const handleToggleTCCB = async (userId: number, isTccb: boolean) => {
    try {
      await api.put(`/admin/nguoi-dung/${userId}`, { la_tccb: isTccb })
      setSuccess(isTccb ? 'Đã cấp quyền TCCB' : 'Đã thu hồi quyền TCCB')
      loadData()
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Lỗi cập nhật')
    }
  }

  const filteredUsers = users.filter(u => 
    !filters.search || 
    u.ho_ten.toLowerCase().includes(filters.search.toLowerCase()) ||
    u.ma_cong_chuc.toLowerCase().includes(filters.search.toLowerCase())
  )

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold">Quản lý người dùng</h2>

      {error && <Alert type="error" onClose={() => setError('')}>{error}</Alert>}
      {success && <Alert type="success" onClose={() => setSuccess('')}>{success}</Alert>}

      {/* Filters */}
      <Card className="p-4">
        <div className="flex flex-wrap gap-4">
          <div className="flex-1 min-w-[200px]">
            <Input
              placeholder="Tìm theo tên hoặc mã..."
              value={filters.search}
              onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
            />
          </div>
          <Select
            value={filters.don_vi_id}
            onChange={(e) => setFilters(prev => ({ ...prev, don_vi_id: e.target.value }))}
          >
            <option value="">Tất cả đơn vị</option>
            {donVis.map(dv => (
              <option key={dv.id} value={dv.id}>{dv.ten_don_vi}</option>
            ))}
          </Select>
          <Select
            value={filters.chuc_vu_id}
            onChange={(e) => setFilters(prev => ({ ...prev, chuc_vu_id: e.target.value }))}
          >
            <option value="">Tất cả chức vụ</option>
            {chucVus.map(cv => (
              <option key={cv.id} value={cv.id}>{cv.ten_chuc_vu}</option>
            ))}
          </Select>
        </div>
      </Card>

      {/* Users Table */}
      <Card>
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Mã CC</th>
                <th>Họ tên</th>
                <th>Đơn vị</th>
                <th>Chức vụ</th>
                <th className="text-center">Cấp LĐ</th>
                <th className="text-center">TCCB</th>
                <th className="text-center">Trạng thái</th>
                <th className="text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map(user => (
                <tr key={user.id}>
                  <td className="font-mono text-sm">{user.ma_cong_chuc}</td>
                  <td className="font-medium">{user.ho_ten}</td>
                  <td>{user.don_vi_ten}</td>
                  <td>{user.chuc_vu_ten}</td>
                  <td className="text-center">{user.cap_lanh_dao}</td>
                  <td className="text-center">
                    {user.la_tccb ? (
                      <Badge color="success">TCCB</Badge>
                    ) : (
                      <span className="text-gray-400">-</span>
                    )}
                  </td>
                  <td className="text-center">
                    <Badge color={user.dang_hoat_dong ? 'success' : 'danger'}>
                      {user.dang_hoat_dong ? 'Hoạt động' : 'Đã khóa'}
                    </Badge>
                  </td>
                  <td className="text-center">
                    <div className="flex gap-1 justify-center">
                      <Button size="sm" variant="secondary" onClick={() => handleResetPassword(user.id)}>
                        Reset MK
                      </Button>
                      <Button 
                        size="sm" 
                        variant={user.dang_hoat_dong ? 'danger' : 'success'}
                        onClick={() => handleToggleActive(user.id, !user.dang_hoat_dong)}
                      >
                        {user.dang_hoat_dong ? 'Khóa' : 'Mở'}
                      </Button>
                      <Button
                        size="sm"
                        variant={user.la_tccb ? 'warning' : 'info'}
                        onClick={() => handleToggleTCCB(user.id, !user.la_tccb)}
                      >
                        {user.la_tccb ? 'Bỏ TCCB' : 'TCCB'}
                      </Button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="p-4 border-t text-sm text-gray-500">
          Hiển thị {filteredUsers.length} / {users.length} người dùng
        </div>
      </Card>
    </div>
  )
}

// Special Cases Management
function SpecialCases() {
  const [cases, setCases] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const res = await api.get('/admin/truong-hop-dac-biet')
      setCases(res.data)
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Lỗi tải dữ liệu')
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (id: number, approved: boolean) => {
    try {
      await api.post(`/admin/truong-hop-dac-biet/${id}/duyet`, { duyet: approved })
      setSuccess(approved ? 'Đã duyệt' : 'Đã từ chối')
      loadData()
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Lỗi xử lý')
    }
  }

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold">Trường hợp đặc biệt</h2>
      <p className="text-gray-600">Xử lý các trường hợp kê khai đặc biệt cần TCCB duyệt</p>

      {error && <Alert type="error" onClose={() => setError('')}>{error}</Alert>}
      {success && <Alert type="success" onClose={() => setSuccess('')}>{success}</Alert>}

      <Card>
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Người đăng ký</th>
                <th>Đơn vị</th>
                <th>Loại</th>
                <th>Mô tả</th>
                <th>Trạng thái</th>
                <th className="text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {cases.length === 0 ? (
                <tr>
                  <td colSpan={6} className="text-center py-8 text-gray-500">
                    Không có trường hợp đặc biệt nào
                  </td>
                </tr>
              ) : (
                cases.map(c => (
                  <tr key={c.id}>
                    <td className="font-medium">{c.nguoi_dung_ten}</td>
                    <td>{c.don_vi_ten}</td>
                    <td>{c.loai}</td>
                    <td className="max-w-xs truncate">{c.mo_ta}</td>
                    <td>
                      <Badge color={c.trang_thai === 'CHO_DUYET' ? 'warning' : c.trang_thai === 'DA_DUYET' ? 'success' : 'danger'}>
                        {c.trang_thai}
                      </Badge>
                    </td>
                    <td className="text-center">
                      {c.trang_thai === 'CHO_DUYET' && (
                        <div className="flex gap-1 justify-center">
                          <Button size="sm" variant="success" onClick={() => handleApprove(c.id, true)}>
                            Duyệt
                          </Button>
                          <Button size="sm" variant="danger" onClick={() => handleApprove(c.id, false)}>
                            Từ chối
                          </Button>
                        </div>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  )
}

// Reports
function Reports() {
  const [thang, setThang] = useState(new Date().getMonth() + 1)
  const [nam, setNam] = useState(new Date().getFullYear())
  const [loading, setLoading] = useState(false)

  const handleExport = async (type: string) => {
    try {
      setLoading(true)
      const res = await api.get(`/admin/bao-cao/${type}`, {
        params: { thang, nam },
        responseType: 'blob',
      })
      const url = window.URL.createObjectURL(new Blob([res.data]))
      const link = document.createElement('a')
      link.href = url
      link.setAttribute('download', `bao-cao-${type}-${thang}-${nam}.xlsx`)
      document.body.appendChild(link)
      link.click()
      link.remove()
    } catch (err) {
      alert('Lỗi xuất báo cáo')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-bold">Báo cáo</h2>

      <Card className="p-4">
        <div className="flex gap-4 items-end">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Tháng</label>
            <Select value={thang} onChange={(e) => setThang(Number(e.target.value))}>
              {Array.from({ length: 12 }, (_, i) => (
                <option key={i + 1} value={i + 1}>Tháng {i + 1}</option>
              ))}
            </Select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Năm</label>
            <Select value={nam} onChange={(e) => setNam(Number(e.target.value))}>
              {[2024, 2025, 2026].map(y => (
                <option key={y} value={y}>{y}</option>
              ))}
            </Select>
          </div>
        </div>
      </Card>

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
        <Card className="p-6">
          <h3 className="font-medium mb-2">Báo cáo KPI</h3>
          <p className="text-sm text-gray-500 mb-4">Tổng hợp điểm KPI toàn Chi cục</p>
          <Button onClick={() => handleExport('kpi')} disabled={loading}>
            Xuất Excel
          </Button>
        </Card>

        <Card className="p-6">
          <h3 className="font-medium mb-2">Báo cáo kê khai</h3>
          <p className="text-sm text-gray-500 mb-4">Chi tiết kê khai sản phẩm</p>
          <Button onClick={() => handleExport('ke-khai')} disabled={loading}>
            Xuất Excel
          </Button>
        </Card>

        <Card className="p-6">
          <h3 className="font-medium mb-2">Báo cáo nghỉ phép</h3>
          <p className="text-sm text-gray-500 mb-4">Tổng hợp ngày nghỉ phép</p>
          <Button onClick={() => handleExport('nghi-phep')} disabled={loading}>
            Xuất Excel
          </Button>
        </Card>
      </div>
    </div>
  )
}

// Main Admin Page
export default function AdminPage() {
  const location = useLocation()
  const { user } = useAuthStore()

  const navItems = [
    { path: '/admin', label: 'Tổng quan', exact: true },
    { path: '/admin/nguoi-dung', label: 'Người dùng' },
    { path: '/admin/dac-biet', label: 'Trường hợp đặc biệt' },
    { path: '/admin/bao-cao', label: 'Báo cáo' },
  ]

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Quản trị hệ thống</h1>
        <Badge color="info">{user?.la_admin ? 'Admin' : 'TCCB'}</Badge>
      </div>

      {/* Sub Navigation */}
      <nav className="flex space-x-4 border-b border-gray-200 pb-2">
        {navItems.map(item => {
          const isActive = item.exact 
            ? location.pathname === item.path
            : location.pathname.startsWith(item.path)
          return (
            <Link
              key={item.path}
              to={item.path}
              className={`px-3 py-2 rounded-t-lg text-sm font-medium ${
                isActive 
                  ? 'bg-blue-100 text-blue-700' 
                  : 'text-gray-500 hover:text-gray-700'
              }`}
            >
              {item.label}
            </Link>
          )
        })}
      </nav>

      {/* Routes */}
      <Routes>
        <Route index element={<AdminDashboard />} />
        <Route path="nguoi-dung" element={<UserManagement />} />
        <Route path="dac-biet" element={<SpecialCases />} />
        <Route path="bao-cao" element={<Reports />} />
      </Routes>
    </div>
  )
}
