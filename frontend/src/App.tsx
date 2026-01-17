import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from './store'
import { Layout } from './components/Layout'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/DashboardPage'
import KeKhaiPage from './pages/KeKhaiPage'
import PheDuyetPage from './pages/PheDuyetPage'
import NhiemVuPage from './pages/NhiemVuPage'
import TieuChiPage from './pages/TieuChiPage'
import NghiPhepPage from './pages/NghiPhepPage'
import KPIPage from './pages/KPIPage'
import AdminPage from './pages/AdminPage'
import ProfilePage from './pages/ProfilePage'

const PrivateRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated } = useAuthStore()
  return isAuthenticated ? <>{children}</> : <Navigate to="/login" replace />
}

const AdminRoute = ({ children }: { children: React.ReactNode }) => {
  const { user, isAuthenticated } = useAuthStore()
  if (!isAuthenticated) return <Navigate to="/login" replace />
  if (!user?.la_admin && !user?.la_tccb) return <Navigate to="/" replace />
  return <>{children}</>
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={
          <PrivateRoute>
            <Layout />
          </PrivateRoute>
        }>
          <Route index element={<DashboardPage />} />
          <Route path="ke-khai" element={<KeKhaiPage />} />
          <Route path="phe-duyet" element={<PheDuyetPage />} />
          <Route path="nhiem-vu" element={<NhiemVuPage />} />
          <Route path="tieu-chi" element={<TieuChiPage />} />
          <Route path="nghi-phep" element={<NghiPhepPage />} />
          <Route path="kpi" element={<KPIPage />} />
          <Route path="profile" element={<ProfilePage />} />
          <Route path="admin/*" element={
            <AdminRoute>
              <AdminPage />
            </AdminRoute>
          } />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  )
}

export default App
