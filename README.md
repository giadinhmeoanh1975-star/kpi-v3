# Hệ thống Quản lý KPI v3.0
## Chi cục Hải quan Khu vực VIII

### 📋 Tổng quan

Hệ thống quản lý KPI (Key Performance Indicators) cho Chi cục Hải quan Khu vực VIII với các chức năng:

- **Kê khai sản phẩm**: Đăng ký công việc hàng ngày theo danh mục sản phẩm
- **Phê duyệt đa cấp**: Workflow phê duyệt theo cấp lãnh đạo
- **Giao nhiệm vụ**: Giao và đánh giá nhiệm vụ cho nhân viên
- **Tiêu chí chung**: Chấm điểm chấm công, kỷ luật, phối hợp
- **Nghỉ phép**: Đăng ký và duyệt nghỉ phép
- **Tính KPI**: Tự động tính điểm KPI hàng tháng

### 🏗️ Kiến trúc hệ thống

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│    Frontend     │────▶│    Backend      │────▶│   PostgreSQL    │
│   React + TS    │     │    FastAPI      │     │      15         │
│   Port: 3000    │     │   Port: 8000    │     │   Port: 5432    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 📁 Cấu trúc thư mục

```
kpi-v3/
├── docker-compose.yml    # Docker Compose configuration
├── database/
│   └── init.sql          # Database schema + 548 employees
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── main.py       # FastAPI entry point
│       ├── core/         # Config, database, security
│       ├── models/       # SQLAlchemy models (15 tables)
│       └── api/          # API routers
│           ├── auth.py       # Đăng nhập
│           ├── danh_muc.py   # Danh mục
│           ├── ke_khai.py    # Kê khai
│           ├── phe_duyet.py  # Phê duyệt
│           ├── nhiem_vu.py   # Nhiệm vụ
│           ├── tieu_chi.py   # Tiêu chí
│           ├── nghi_phep.py  # Nghỉ phép
│           ├── kpi.py        # KPI
│           └── admin.py      # Quản trị
└── frontend/
    ├── Dockerfile
    ├── nginx.conf
    ├── package.json
    └── src/
        ├── App.tsx       # Routes
        ├── api/          # Axios instance
        ├── components/   # UI components
        ├── pages/        # Page components
        ├── store/        # Zustand state
        └── types/        # TypeScript types
```

### 🚀 Cài đặt và chạy

#### Yêu cầu
- Docker & Docker Compose
- Node.js 20+ (development)
- Python 3.11+ (development)

#### Chạy với Docker (Khuyến nghị)

```bash
# Clone hoặc copy project
cd kpi-v3

# Khởi động tất cả services
docker-compose up -d

# Kiểm tra logs
docker-compose logs -f

# Dừng services
docker-compose down
```

Sau khi khởi động:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

#### Chạy Development

**Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

### 👥 Dữ liệu người dùng

Hệ thống được cài đặt sẵn **548 nhân viên** từ 14 đơn vị:

| Đơn vị | Mã | Số lượng |
|--------|-----|----------|
| Lãnh đạo Chi cục | LDCC | 4 |
| Văn phòng | VP | 41 |
| Tổ chức cán bộ | TCCB | 14 |
| Nghiệp vụ Hải quan | NVHQ | 19 |
| Quản lý rủi ro | QLRR | 8 |
| Công nghệ thông tin | CNTT | 11 |
| Kiểm soát Hải quan | KSHQ | 72 |
| Phòng TKTSTQ | PTKTSTQ | 21 |
| Hải quan Gia Lâm | HGAI | 79 |
| Đội VGAI | VGIA | 50 |
| Cảng Phà | CPHA | 40 |
| Hưng Mô | HMO | 36 |
| Móng Cái | MCAI | 134 |
| Bắc Phong Sinh | BPS | 19 |

### 🔐 Đăng nhập

**Mật khẩu mặc định**: `123456`

**Tài khoản test theo cấp:**

| Cấp | Chức vụ | Tài khoản mẫu |
|-----|---------|---------------|
| 1 | Chi cục trưởng | (xem trong database) |
| 2 | Phó Chi cục trưởng | (xem trong database) |
| 3 | Trưởng phòng/Đội trưởng | (xem trong database) |
| 4 | Phó phòng/Phó đội | (xem trong database) |
| 5 | Công chức | (xem trong database) |
| 6 | Hợp đồng | (xem trong database) |

**Admin**: `admin` / `123456`

### 📊 Workflow phê duyệt

```
Cấp 5,6 (CC, HĐ)
    │
    ▼ Chọn lãnh đạo phê duyệt
    │
    ├──▶ Cấp 4 (Phó phòng) ──▶ Cấp 3 (Trưởng phòng)
    │                              │
    └──▶ Cấp 3 (Trưởng phòng) ◀───┘
              │
              ▼
         Cấp 2 (PCCT)
              │
              ▼
         Cấp 1 (CCT) ◀── Tự kê khai
```

**Quy tắc:**
- Cấp 5, 6: Chọn Phó phòng HOẶC Trưởng phòng cùng đơn vị
- Cấp 4: Được duyệt bởi Trưởng phòng cùng đơn vị
- Cấp 3: Được duyệt bởi PCCT hoặc CCT
- Cấp 2: Được duyệt bởi CCT
- Cấp 1: Tự kê khai, không cần duyệt

### 📈 Cách tính KPI

```
Tổng điểm = Điểm sản phẩm + Điểm tiêu chí + Điểm nhiệm vụ + Điểm lãnh đạo

Điểm sản phẩm: Tối đa 60 điểm (tổng hệ số × số lượng)
Điểm tiêu chí: Tối đa 30 điểm (chấm công + kỷ luật + phối hợp)
Điểm nhiệm vụ: ±10 điểm (từ đánh giá nhiệm vụ được giao)
Điểm lãnh đạo: Theo đánh giá (D/Đ/E)

Xếp loại:
- A (Xuất sắc): ≥ 90 điểm
- B (Tốt): 70-89 điểm
- C (Đạt): 50-69 điểm
- D (Không đạt): < 50 điểm
```

### 🔧 Tính năng đã khắc phục

So với phiên bản trước (theo Thieu_sot.docx):

1. ✅ Công chức có thể chọn Phó phòng hoặc Trưởng phòng để phê duyệt
2. ✅ Trưởng phòng có chức năng phê duyệt chất lượng công việc của Phó phòng
3. ✅ Chi cục trưởng có chức năng phê duyệt PCCT, ĐT, TP và tự kê khai
4. ✅ Có đầy đủ tài khoản Phó phòng để test
5. ✅ Có tài khoản Admin để test
6. ✅ Có tài khoản TCCB để duyệt nghỉ phép và trường hợp đặc biệt
7. ✅ Có tài khoản PCCT để test

### 📝 API Endpoints

| Endpoint | Mô tả |
|----------|-------|
| POST /api/auth/login | Đăng nhập |
| GET /api/danh-muc/* | Danh mục hệ thống |
| GET/POST /api/ke-khai/* | Kê khai sản phẩm |
| GET/POST /api/phe-duyet/* | Phê duyệt |
| GET/POST /api/nhiem-vu/* | Nhiệm vụ |
| GET/POST /api/tieu-chi/* | Tiêu chí chung |
| GET/POST /api/nghi-phep/* | Nghỉ phép |
| GET/POST /api/kpi/* | KPI |
| GET/POST /api/admin/* | Quản trị |

Chi tiết API: http://localhost:8000/docs

### 🛠️ Công nghệ sử dụng

**Backend:**
- FastAPI 0.109
- SQLAlchemy 2.0 (async)
- PostgreSQL 15
- JWT Authentication

**Frontend:**
- React 18
- TypeScript
- Vite 5
- TailwindCSS 3
- Zustand (state management)
- React Router 6

### 📞 Hỗ trợ

Nếu gặp vấn đề:
1. Kiểm tra logs: `docker-compose logs`
2. Restart services: `docker-compose restart`
3. Reset database: `docker-compose down -v && docker-compose up -d`

---
**Version 3.0** - Chi cục Hải quan Khu vực VIII
