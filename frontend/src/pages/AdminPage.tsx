import { useState, useEffect } from 'react'
import { Routes, Route, Link, useLocation } from 'react-router-dom'
import { useAuthStore } from '../store'
import { api } from '../api'
// @ts-ignore
import { Button, Card, Select, Input, Badge, Alert, LoadingSpinner } from '../components/ui'

// Admin Dashboard
function AdminDashboard() {
  const [stats, setStats] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      const res = await api.admin.getDashboard()
      setStats(res)
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
          <div className="text-3xl font-bold text-green-600">{stats?.ke_khai_thang_nay || 0}</div>
          <div className="text-sm text-gray-500">Tổng kê khai</div>
        </Card>
        <Card className="p-4 text-center">
          <div className="text-3xl font-bold text-yellow-600">{stats?.nguoi_dung_hoat_dong || 0}</div>
          <div className="text-sm text-gray-500">Đang hoạt động</div>
        </Card>
        <Card className="p-4 text-center">
          <div className="text-3xl font-bold text-purple-600">{stats?.kpi_da_tinh || 0}</div>
          <div className="text-sm text-gray-500">KPI đã tính</div>
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

  useEffect(() => {
    loadData()
  }, [filters.don_vi_id, filters.chuc_vu_id])

  const loadData = async () => {
    try {
      setLoading(true)
      const [usersRes, donViRes, chucVuRes] = await Promise.all([
        api.admin.getUsers({
          don_vi_id: filters.don_vi_id ? Number(filters.don_vi_id) : undefined,
          search: filters.search
        }),
        api.danhMuc.getDonVi(),
        api.danhMuc.getChucVu(),
      ])
      setUsers(usersRes)
      setDonVis(donViRes)
      setChucVus(chucVuRes)
    } catch (err: any) {
      setError(err.message || 'Lỗi tải dữ liệu')
    } finally {
      setLoading(false)
    }
  }

  const handleResetPassword = async (userId: number) => {
    if (!confirm('Reset mật khẩu về 123456?')) return
    try {
      await api.admin.resetPassword(userId)
      setSuccess('Đã reset mật khẩu thành công')
    } catch (err: any) {
      setError(err.message || 'Lỗi reset mật khẩu')
    }
  }

  const handleToggleActive = async (userId: number, active: boolean) => {
    try {
      await api.admin.toggleStatus(userId)
      setSuccess('Đã cập nhật trạng thái')
      loadData()
    } catch (err: any) {
      setError(err.message || 'Lỗi cập nhật')
    }
  }

  const handleToggleTCCB = async (userId: number, isTccb: boolean) => {
    try {
      await api.admin.updateUser(userId, { la_tccb: isTccb })
      setSuccess(isTccb ? 'Đã cấp quyền TCCB' : 'Đã thu hồi quyền TCCB')
      loadData()
    } catch (err: any) {
      setError(err.message || 'Lỗi cập nhật')
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
          {/* @ts-ignore */}
          <Select
            value={filters.don_vi_id}
            onChange={(e) => setFilters(prev => ({ ...prev, don_vi_id: e.target.value }))}
          >
            <option value="">Tất cả đơn vị</option>
            {donVis.map(dv => (
              <option key={dv.id} value={dv.id}>{dv.ten_don_vi}</option>
            ))}
          </Select>
          {/* @ts-ignore */}
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
                       // @ts-ignore
                      <Badge color="success">TCCB</Badge>
                    ) : (
                      <span className="text-gray-400">-</span>
                    )}
                  </td>
                  <td className="text-center">
                     {/* @ts-ignore */}
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
      </Card>
    </div>
  )
}

// Special Cases Management
function SpecialCases() {
   // Placeholder for special cases if needed later
   return <div>Tính năng đang phát triển</div>
}

// Reports
function Reports() {
   // Placeholder for reports
   return <div>Tính năng báo cáo</div>
}

// Main Admin Page - Sửa export thành Named Export
export function AdminPage() {
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
         {/* @ts-ignore */}
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