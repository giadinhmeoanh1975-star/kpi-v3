import { useState, useEffect } from 'react'
import { useAuthStore } from '../store'
import { api } from '../api'
// @ts-ignore
import { Button, Card, Select, Badge, Alert, LoadingSpinner } from '../components/ui'

interface KPIThang {
  id: number
  thang: number
  nam: number
  diem_san_pham: number
  diem_tieu_chi: number
  diem_nhiem_vu: number
  diem_lanh_dao: number
  tong_diem: number
  xep_loai: string
  ghi_chu: string | null
}

interface ThongKeKPI {
  trung_binh_diem: number
  so_thang_a: number
  so_thang_b: number
  so_thang_c: number
  so_thang_d: number
}

const XEP_LOAI_COLORS: Record<string, string> = {
  A: 'success',
  B: 'info',
  C: 'warning',
  D: 'danger',
}

const XEP_LOAI_LABELS: Record<string, string> = {
  A: 'Xuất sắc',
  B: 'Tốt',
  C: 'Đạt',
  D: 'Không đạt',
}

// Sửa thành Named Export
export function KPIPage() {
  const { user } = useAuthStore()
  const [kpis, setKpis] = useState<KPIThang[]>([])
  const [thongKe, setThongKe] = useState<ThongKeKPI | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  
  const [nam, setNam] = useState(new Date().getFullYear())
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [selectedKPI, setSelectedKPI] = useState<KPIThang | null>(null)

  useEffect(() => {
    loadData()
  }, [nam])

  const loadData = async () => {
    try {
      setLoading(true)
      const [kpiRes] = await Promise.all([
        api.kpi.getMyKPI(undefined, nam),
        // api.kpi.getThongKe() // Nếu API này chưa có thì comment lại
      ])
      // Vì API getMyKPI trả về object hoặc null, ta cần xử lý
      if (kpiRes) {
         setKpis([kpiRes]) // Tạm thời
      }
    } catch (err: any) {
      setError(err.message || 'Lỗi tải dữ liệu')
    } finally {
      setLoading(false)
    }
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const handleTinhKPI = async (thang: number) => {
    try {
      await api.kpi.calculate(thang, nam)
      loadData()
    } catch (err: any) {
      setError(err.message || 'Lỗi tính KPI')
    }
  }

  if (loading) return <LoadingSpinner />

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold text-gray-900">Kết quả KPI</h1>
        <div className="flex items-center gap-4">
           {/* @ts-ignore */}
          <Select value={nam} onChange={(e) => setNam(Number(e.target.value))}>
            {[2024, 2025, 2026].map(y => (
              <option key={y} value={y}>Năm {y}</option>
            ))}
          </Select>
        </div>
      </div>

      {error && <Alert type="error" onClose={() => setError('')}>{error}</Alert>}

      {/* Summary Stats */}
      {thongKe && (
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
          <Card className="text-center p-4">
            <div className="text-3xl font-bold text-blue-600">{thongKe.trung_binh_diem.toFixed(1)}</div>
            <div className="text-sm text-gray-500">Điểm TB năm</div>
          </Card>
          <Card className="text-center p-4 border-green-200 bg-green-50">
            <div className="text-2xl font-bold text-green-600">{thongKe.so_thang_a}</div>
            <div className="text-sm text-green-700">Tháng xếp loại A</div>
          </Card>
          <Card className="text-center p-4 border-blue-200 bg-blue-50">
            <div className="text-2xl font-bold text-blue-600">{thongKe.so_thang_b}</div>
            <div className="text-sm text-blue-700">Tháng xếp loại B</div>
          </Card>
          <Card className="text-center p-4 border-yellow-200 bg-yellow-50">
            <div className="text-2xl font-bold text-yellow-600">{thongKe.so_thang_c}</div>
            <div className="text-sm text-yellow-700">Tháng xếp loại C</div>
          </Card>
          <Card className="text-center p-4 border-red-200 bg-red-50">
            <div className="text-2xl font-bold text-red-600">{thongKe.so_thang_d}</div>
            <div className="text-sm text-red-700">Tháng xếp loại D</div>
          </Card>
        </div>
      )}

      {/* KPI Breakdown Info */}
      <Card className="p-4 bg-gray-50">
        <h3 className="font-medium text-gray-900 mb-2">Cách tính điểm KPI</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
          <div>
            <span className="text-gray-600">Điểm sản phẩm:</span>
            <span className="ml-1 font-medium">Tối đa 60 điểm</span>
          </div>
          <div>
            <span className="text-gray-600">Tiêu chí chung:</span>
            <span className="ml-1 font-medium">Tối đa 30 điểm</span>
          </div>
          <div>
            <span className="text-gray-600">Nhiệm vụ giao:</span>
            <span className="ml-1 font-medium">±10 điểm</span>
          </div>
          <div>
            <span className="text-gray-600">Đánh giá LĐ:</span>
            <span className="ml-1 font-medium">D/Đ/E</span>
          </div>
        </div>
        <div className="mt-3 pt-3 border-t border-gray-200">
           {/* @ts-ignore */}
          <span className="text-sm text-gray-600">Xếp loại: </span>
          <span className="text-sm"><Badge color="success">A ≥ 90</Badge></span>
          <span className="text-sm ml-2"><Badge color="info">B ≥ 70</Badge></span>
          <span className="text-sm ml-2"><Badge color="warning">C ≥ 50</Badge></span>
          <span className="text-sm ml-2"><Badge color="danger">D &lt; 50</Badge></span>
        </div>
      </Card>

      {/* Monthly KPI Table */}
      <Card>
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Tháng</th>
                <th className="text-center">Điểm SP</th>
                <th className="text-center">Tiêu chí</th>
                <th className="text-center">Nhiệm vụ</th>
                <th className="text-center">Lãnh đạo</th>
                <th className="text-center">Tổng điểm</th>
                <th className="text-center">Xếp loại</th>
                <th>Ghi chú</th>
              </tr>
            </thead>
            <tbody>
              {Array.from({ length: 12 }, (_, i) => i + 1).map(thang => {
                const kpi = kpis.find(k => k.thang === thang)
                return (
                  <tr key={thang} className={!kpi ? 'bg-gray-50' : ''}>
                    <td className="font-medium">Tháng {thang}</td>
                    <td className="text-center">{kpi?.diem_san_pham.toFixed(1) || '-'}</td>
                    <td className="text-center">{kpi?.diem_tieu_chi.toFixed(1) || '-'}</td>
                    <td className="text-center">{kpi?.diem_nhiem_vu ? (kpi.diem_nhiem_vu > 0 ? '+' : '') + kpi.diem_nhiem_vu.toFixed(1) : '-'}</td>
                    <td className="text-center">{kpi?.diem_lanh_dao.toFixed(1) || '-'}</td>
                    <td className="text-center font-bold">{kpi?.tong_diem.toFixed(1) || '-'}</td>
                    <td className="text-center">
                      {kpi ? (
                         // @ts-ignore
                        <Badge color={XEP_LOAI_COLORS[kpi.xep_loai] || 'gray'}>
                          {kpi.xep_loai} - {XEP_LOAI_LABELS[kpi.xep_loai]}
                        </Badge>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </td>
                    <td className="text-gray-500">{kpi?.ghi_chu || '-'}</td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  )
}