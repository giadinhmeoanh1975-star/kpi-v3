-- ===============================================
-- KPI SYSTEM - CHI CỤC HẢI QUAN KHU VỰC VIII
-- Version 3.0 - Hoàn chỉnh với 548 công chức
-- ===============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===============================================
-- 1. DANH MỤC ĐƠN VỊ
-- ===============================================
CREATE TABLE IF NOT EXISTS dm_don_vi (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ma_don_vi VARCHAR(20) UNIQUE NOT NULL,
    ten_don_vi VARCHAR(200) NOT NULL,
    ten_viet_tat VARCHAR(50),
    loai_don_vi VARCHAR(30),
    thu_tu INT DEFAULT 0,
    trang_thai BOOLEAN DEFAULT TRUE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO dm_don_vi (ma_don_vi, ten_don_vi, ten_viet_tat, loai_don_vi, thu_tu) VALUES
('LDCC', 'Lãnh đạo Chi cục', 'LĐCC', 'Lãnh đạo', 0),
('VP', 'Văn phòng', 'VP', 'Phòng', 1),
('TCCB', 'Phòng Tổ chức cán bộ', 'TCCB', 'Phòng', 2),
('NVHQ', 'Phòng Nghiệp vụ Hải quan', 'NVHQ', 'Phòng', 3),
('QLRR', 'Phòng Quản lý rủi ro', 'QLRR', 'Phòng', 4),
('CNTT', 'Phòng Công nghệ thông tin', 'CNTT', 'Phòng', 5),
('KSHQ', 'Đội Kiểm soát Hải quan', 'KSHQ', 'Đội', 6),
('PTKTSTQ', 'Đội Phúc tập và Kiểm tra sau thông quan', 'PT&KTSTQ', 'Đội', 7),
('HGAI', 'Hải quan cửa khẩu cảng Hòn Gai', 'HQ Hòn Gai', 'Cửa khẩu', 8),
('VGIA', 'Hải quan cửa khẩu cảng Vạn Gia', 'HQ Vạn Gia', 'Cửa khẩu', 9),
('CPHA', 'Hải quan cửa khẩu cảng Cẩm Phả', 'HQ Cẩm Phả', 'Cửa khẩu', 10),
('HMO', 'Hải quan cửa khẩu Hoành Mô', 'HQ Hoành Mô', 'Cửa khẩu', 11),
('MCAI', 'Hải quan cửa khẩu quốc tế Móng Cái', 'HQ Móng Cái', 'Cửa khẩu', 12),
('BPS', 'Hải quan cửa khẩu Bắc Phong Sinh', 'HQ Bắc Phong Sinh', 'Cửa khẩu', 13)
ON CONFLICT (ma_don_vi) DO NOTHING;

-- ===============================================
-- 2. DANH MỤC CHỨC VỤ
-- ===============================================
CREATE TABLE IF NOT EXISTS dm_chuc_vu (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ma_chuc_vu VARCHAR(10) UNIQUE NOT NULL,
    ten_chuc_vu VARCHAR(100) NOT NULL,
    la_lanh_dao BOOLEAN DEFAULT FALSE,
    cap_lanh_dao INT DEFAULT 0,
    -- Cap: 1=CCT, 2=PCCT, 3=TP/DT/CVP, 4=PTP/PDT/PVP, 5=Công chức, 6=Hợp đồng
    co_the_phe_duyet BOOLEAN DEFAULT FALSE,
    co_the_ke_khai BOOLEAN DEFAULT TRUE,
    thu_tu INT DEFAULT 0,
    trang_thai BOOLEAN DEFAULT TRUE
);

INSERT INTO dm_chuc_vu (ma_chuc_vu, ten_chuc_vu, la_lanh_dao, cap_lanh_dao, co_the_phe_duyet, co_the_ke_khai, thu_tu) VALUES
('CCT', 'Chi cục trưởng', TRUE, 1, TRUE, TRUE, 1),
('PCCT', 'Phó Chi cục trưởng', TRUE, 2, TRUE, TRUE, 2),
('TP', 'Trưởng phòng', TRUE, 3, TRUE, TRUE, 3),
('CVP', 'Chánh Văn phòng', TRUE, 3, TRUE, TRUE, 4),
('DT', 'Đội trưởng', TRUE, 3, TRUE, TRUE, 5),
('PTP', 'Phó Trưởng phòng', TRUE, 4, TRUE, TRUE, 6),
('PVP', 'Phó Chánh Văn phòng', TRUE, 4, TRUE, TRUE, 7),
('PDT', 'Phó Đội trưởng', TRUE, 4, TRUE, TRUE, 8),
('CC', 'Công chức', FALSE, 5, FALSE, TRUE, 9),
('HD', 'Hợp đồng 111', FALSE, 6, FALSE, TRUE, 10)
ON CONFLICT (ma_chuc_vu) DO NOTHING;

-- ===============================================
-- 3. DANH MỤC SẢN PHẨM CHUẨN
-- ===============================================
CREATE TABLE IF NOT EXISTS dm_san_pham (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ma_san_pham VARCHAR(20) UNIQUE NOT NULL,
    ten_san_pham VARCHAR(300) NOT NULL,
    don_vi_tinh VARCHAR(50),
    thoi_gian_chuan INT DEFAULT 60,
    thu_tu INT DEFAULT 0,
    trang_thai BOOLEAN DEFAULT TRUE
);

INSERT INTO dm_san_pham (ma_san_pham, ten_san_pham, don_vi_tinh, thoi_gian_chuan, thu_tu) VALUES
('SP01', 'Văn bản hành chính thông thường', 'Văn bản', 60, 1),
('SP02', 'Văn bản hành chính phức tạp', 'Văn bản', 120, 2),
('SP03', 'Tờ khai được kiểm tra chi tiết hồ sơ', 'Tờ khai', 10, 3),
('SP04', 'Tờ khai được kiểm hóa', 'Tờ khai', 15, 4),
('SP05', 'Giờ trực nghiệp vụ', 'Giờ', 60, 5),
('SP06', 'Giờ tuần tra kiểm soát', 'Giờ', 60, 6),
('SP07', 'Hồ sơ kiểm tra sau thông quan', 'Hồ sơ', 480, 7),
('SP08', 'Báo cáo phân tích rủi ro', 'Báo cáo', 240, 8),
('SP09', 'Xử lý vi phạm hành chính', 'Vụ việc', 180, 9),
('SP10', 'Hỗ trợ kỹ thuật CNTT', 'Lượt', 30, 10)
ON CONFLICT (ma_san_pham) DO NOTHING;

-- ===============================================
-- 4. DANH MỤC MỨC ĐỘ PHỨC TẠP
-- ===============================================
CREATE TABLE IF NOT EXISTS dm_muc_do (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ma_muc_do VARCHAR(10) UNIQUE NOT NULL,
    ten_muc_do VARCHAR(50) NOT NULL,
    mo_ta TEXT,
    cho_phep_tu_nhap_he_so BOOLEAN DEFAULT FALSE,
    thu_tu INT DEFAULT 0,
    trang_thai BOOLEAN DEFAULT TRUE
);

INSERT INTO dm_muc_do (ma_muc_do, ten_muc_do, mo_ta, cho_phep_tu_nhap_he_so, thu_tu) VALUES
('1', 'Giản đơn', 'Công việc đơn giản, thường xuyên', FALSE, 1),
('2', 'Thông thường', 'Công việc có độ phức tạp trung bình', FALSE, 2),
('3', 'Nâng cao', 'Công việc cần kỹ năng chuyên môn cao', FALSE, 3),
('4', 'Phức tạp', 'Công việc phức tạp, nhiều bước', FALSE, 4),
('5', 'Đặc thù', 'Công việc đặc thù, cho phép tự nhập hệ số', TRUE, 5)
ON CONFLICT (ma_muc_do) DO NOTHING;

-- ===============================================
-- 5. HỆ SỐ QUY ĐỔI
-- ===============================================
CREATE TABLE IF NOT EXISTS dm_he_so (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    san_pham_id UUID REFERENCES dm_san_pham(id),
    muc_do_id UUID REFERENCES dm_muc_do(id),
    he_so DECIMAL(10,2) NOT NULL,
    trang_thai BOOLEAN DEFAULT TRUE,
    UNIQUE(san_pham_id, muc_do_id)
);

-- ===============================================
-- 6. NGÀY LỄ
-- ===============================================
CREATE TABLE IF NOT EXISTS dm_ngay_le (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ngay DATE NOT NULL,
    ten_ngay_le VARCHAR(200) NOT NULL,
    nam INT NOT NULL,
    trang_thai BOOLEAN DEFAULT TRUE,
    UNIQUE(ngay)
);

INSERT INTO dm_ngay_le (ngay, ten_ngay_le, nam) VALUES
('2025-01-01', 'Tết Dương lịch', 2025),
('2025-01-28', 'Tết Nguyên đán (29 Tết)', 2025),
('2025-01-29', 'Tết Nguyên đán (30 Tết)', 2025),
('2025-01-30', 'Tết Nguyên đán (Mùng 1)', 2025),
('2025-01-31', 'Tết Nguyên đán (Mùng 2)', 2025),
('2025-02-01', 'Tết Nguyên đán (Mùng 3)', 2025),
('2025-02-02', 'Tết Nguyên đán (Mùng 4)', 2025),
('2025-04-07', 'Giỗ Tổ Hùng Vương', 2025),
('2025-04-30', 'Ngày Giải phóng miền Nam', 2025),
('2025-05-01', 'Ngày Quốc tế Lao động', 2025),
('2025-09-02', 'Ngày Quốc khánh', 2025),
('2025-09-03', 'Ngày Quốc khánh (nghỉ bù)', 2025)
ON CONFLICT (ngay) DO NOTHING;

-- ===============================================
-- 7. BẢNG NGƯỜI DÙNG
-- ===============================================
CREATE TABLE IF NOT EXISTS nguoi_dung (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ma_cong_chuc VARCHAR(30) UNIQUE NOT NULL,
    mat_khau VARCHAR(255) NOT NULL,
    ho_ten VARCHAR(200) NOT NULL,
    nam_sinh VARCHAR(20),
    don_vi_id UUID REFERENCES dm_don_vi(id),
    chuc_vu_id UUID REFERENCES dm_chuc_vu(id),
    email VARCHAR(100),
    so_dien_thoai VARCHAR(20),
    la_admin BOOLEAN DEFAULT FALSE,
    la_tccb BOOLEAN DEFAULT FALSE,
    lanh_dao_truc_tiep_id UUID REFERENCES nguoi_dung(id),
    trang_thai BOOLEAN DEFAULT TRUE,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- 8. BẢNG KÊ KHAI CÔNG VIỆC
-- ===============================================
CREATE TABLE IF NOT EXISTS ke_khai (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_dung_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    thang INT NOT NULL CHECK (thang >= 1 AND thang <= 12),
    nam INT NOT NULL CHECK (nam >= 2020),
    san_pham_id UUID REFERENCES dm_san_pham(id),
    so_luong INT DEFAULT 1,
    ket_qua TEXT,
    muc_do_id UUID REFERENCES dm_muc_do(id),
    he_so DECIMAL(10,2),
    he_so_tu_nhap DECIMAL(10,2),
    tien_do VARCHAR(20) DEFAULT 'DAT' CHECK (tien_do IN ('DAT', 'KHONG_DAT')),
    chat_luong VARCHAR(20) DEFAULT 'DAT' CHECK (chat_luong IN ('DAT', 'KHONG_DAT')),
    so_lan_khong_dat_tien_do INT DEFAULT 0,
    so_lan_khong_dat_chat_luong INT DEFAULT 0,
    lanh_dao_giao_viec_id UUID REFERENCES nguoi_dung(id),
    lanh_dao_phe_duyet_id UUID REFERENCES nguoi_dung(id),
    trang_thai VARCHAR(30) DEFAULT 'NHAP' CHECK (trang_thai IN ('NHAP', 'CHO_DUYET', 'DA_DUYET', 'TU_CHOI', 'YEU_CAU_SUA')),
    nguoi_duyet_id UUID REFERENCES nguoi_dung(id),
    ngay_duyet TIMESTAMP,
    ly_do_tu_choi TEXT,
    ghi_chu TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_ke_khai_nguoi_dung ON ke_khai(nguoi_dung_id);
CREATE INDEX IF NOT EXISTS idx_ke_khai_thang_nam ON ke_khai(thang, nam);
CREATE INDEX IF NOT EXISTS idx_ke_khai_trang_thai ON ke_khai(trang_thai);

-- ===============================================
-- 9. BẢNG NHIỆM VỤ (Lãnh đạo giao việc)
-- ===============================================
CREATE TABLE IF NOT EXISTS nhiem_vu (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_giao_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    nguoi_nhan_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    thang INT NOT NULL,
    nam INT NOT NULL,
    noi_dung TEXT NOT NULL,
    san_pham_id UUID REFERENCES dm_san_pham(id),
    muc_do_id UUID REFERENCES dm_muc_do(id),
    han_hoan_thanh DATE,
    ket_qua_mong_doi TEXT,
    -- Đánh giá của người nhận (tự đánh giá)
    tu_danh_gia_hoan_thanh VARCHAR(20) CHECK (tu_danh_gia_hoan_thanh IN ('HOAN_THANH', 'CHUA_HOAN_THANH', 'DANG_THUC_HIEN')),
    tu_danh_gia_tien_do VARCHAR(20) CHECK (tu_danh_gia_tien_do IN ('DAT', 'KHONG_DAT')),
    tu_danh_gia_chat_luong VARCHAR(20) CHECK (tu_danh_gia_chat_luong IN ('DAT', 'KHONG_DAT')),
    tu_danh_gia_ghi_chu TEXT,
    -- Đánh giá của lãnh đạo
    danh_gia_hoan_thanh VARCHAR(20) CHECK (danh_gia_hoan_thanh IN ('HOAN_THANH', 'CHUA_HOAN_THANH', 'DANG_THUC_HIEN')),
    danh_gia_tien_do VARCHAR(20) CHECK (danh_gia_tien_do IN ('DAT', 'KHONG_DAT')),
    danh_gia_chat_luong VARCHAR(20) CHECK (danh_gia_chat_luong IN ('DAT', 'KHONG_DAT')),
    so_lan_khong_dat_tien_do INT DEFAULT 0,
    so_lan_khong_dat_chat_luong INT DEFAULT 0,
    danh_gia_ghi_chu TEXT,
    trang_thai VARCHAR(30) DEFAULT 'MOI_GIAO' CHECK (trang_thai IN ('MOI_GIAO', 'DANG_THUC_HIEN', 'CHO_DANH_GIA', 'DA_DANH_GIA', 'HUY')),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_nhiem_vu_nguoi_giao ON nhiem_vu(nguoi_giao_id);
CREATE INDEX IF NOT EXISTS idx_nhiem_vu_nguoi_nhan ON nhiem_vu(nguoi_nhan_id);
CREATE INDEX IF NOT EXISTS idx_nhiem_vu_thang_nam ON nhiem_vu(thang, nam);

-- ===============================================
-- 10. BẢNG TIÊU CHÍ CHUNG
-- ===============================================
CREATE TABLE IF NOT EXISTS tieu_chi_chung (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_dung_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    thang INT NOT NULL,
    nam INT NOT NULL,
    -- Tiêu chí 1a: Vi phạm kỷ luật
    tc_1a_vi_pham BOOLEAN DEFAULT FALSE,
    tc_1a_ten_vb VARCHAR(500),
    tc_1a_diem DECIMAL(4,2) DEFAULT 5,
    -- Tiêu chí 1b: Vi phạm khác
    tc_1b_vi_pham BOOLEAN DEFAULT FALSE,
    tc_1b_ten_vb VARCHAR(500),
    tc_1b_diem DECIMAL(4,2) DEFAULT 5,
    -- Tiêu chí 2a: Thực hiện quy chế
    tc_2a_dap_ung BOOLEAN DEFAULT TRUE,
    tc_2a_diem DECIMAL(4,2) DEFAULT 2.5,
    -- Tiêu chí 2b: Thái độ làm việc
    tc_2b_dap_ung BOOLEAN DEFAULT TRUE,
    tc_2b_diem DECIMAL(4,2) DEFAULT 2.5,
    -- Tiêu chí 2c: Phối hợp công tác
    tc_2c_dap_ung BOOLEAN DEFAULT TRUE,
    tc_2c_diem DECIMAL(4,2) DEFAULT 2.5,
    -- Tiêu chí 2d: Tính kỷ luật
    tc_2d_dap_ung BOOLEAN DEFAULT TRUE,
    tc_2d_diem DECIMAL(4,2) DEFAULT 2.5,
    -- Tiêu chí 3: Học tập, bồi dưỡng
    tc_3_dap_ung BOOLEAN DEFAULT TRUE,
    tc_3_diem DECIMAL(4,2) DEFAULT 5,
    -- Tổng điểm tiêu chí chung
    tong_diem_tc DECIMAL(5,2) DEFAULT 30,
    nguoi_danh_gia_id UUID REFERENCES nguoi_dung(id),
    ghi_chu TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nguoi_dung_id, thang, nam)
);

-- ===============================================
-- 11. BẢNG ĐIỂM LÃNH ĐẠO (D, Đ, E)
-- ===============================================
CREATE TABLE IF NOT EXISTS diem_lanh_dao (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_dung_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    thang INT NOT NULL,
    nam INT NOT NULL,
    -- Điểm D: Kết quả chỉ đạo điều hành
    diem_d DECIMAL(5,2),
    diem_d_ghi_chu TEXT,
    -- Điểm Đ: Năng lực tổ chức
    diem_dd DECIMAL(5,2),
    diem_dd_ghi_chu TEXT,
    -- Điểm E: Ý thức trách nhiệm
    diem_e DECIMAL(5,2),
    diem_e_ghi_chu TEXT,
    nguoi_danh_gia_id UUID REFERENCES nguoi_dung(id),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ngay_cap_nhat TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nguoi_dung_id, thang, nam)
);

-- ===============================================
-- 12. BẢNG NGHỈ PHÉP
-- ===============================================
CREATE TABLE IF NOT EXISTS nghi_phep (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_dung_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    tu_ngay DATE NOT NULL,
    den_ngay DATE NOT NULL,
    so_ngay DECIMAL(4,1) NOT NULL,
    loai_nghi VARCHAR(50) DEFAULT 'PHEP_NAM' CHECK (loai_nghi IN ('PHEP_NAM', 'VIEC_RIENG', 'OM', 'THAI_SAN', 'KHAC')),
    ly_do TEXT,
    trang_thai VARCHAR(20) DEFAULT 'CHO_DUYET' CHECK (trang_thai IN ('CHO_DUYET', 'DA_DUYET', 'TU_CHOI', 'HUY')),
    nguoi_duyet_id UUID REFERENCES nguoi_dung(id),
    ngay_duyet TIMESTAMP,
    ly_do_tu_choi TEXT,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- 13. BẢNG TRƯỜNG HỢP ĐẶC BIỆT
-- ===============================================
CREATE TABLE IF NOT EXISTS truong_hop_dac_biet (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_dung_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    thang INT NOT NULL,
    nam INT NOT NULL,
    loai VARCHAR(50) NOT NULL CHECK (loai IN ('MOI_TUYEN', 'NGHI_DAI_HAN', 'LUAN_CHUYEN', 'KHAC')),
    khong_danh_gia BOOLEAN DEFAULT FALSE,
    tru_30_diem BOOLEAN DEFAULT FALSE,
    so_thang_tru INT DEFAULT 0,
    ghi_chu TEXT,
    nguoi_tao_id UUID REFERENCES nguoi_dung(id),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nguoi_dung_id, thang, nam, loai)
);

-- ===============================================
-- 14. BẢNG KPI THÁNG (Kết quả tổng hợp)
-- ===============================================
CREATE TABLE IF NOT EXISTS kpi_thang (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_dung_id UUID REFERENCES nguoi_dung(id) NOT NULL,
    thang INT NOT NULL,
    nam INT NOT NULL,
    la_lanh_dao BOOLEAN DEFAULT FALSE,
    -- Điểm thành phần
    diem_a DECIMAL(8,4) DEFAULT 0,
    diem_b DECIMAL(8,4) DEFAULT 0,
    diem_c DECIMAL(8,4) DEFAULT 0,
    diem_d DECIMAL(8,4),
    diem_dd DECIMAL(8,4),
    diem_e DECIMAL(8,4),
    -- Điểm KPI và tiêu chí chung
    diem_kpi DECIMAL(8,4) DEFAULT 0,
    diem_tieu_chi_chung DECIMAL(5,2) DEFAULT 30,
    -- Tổng điểm và xếp loại
    tong_diem DECIMAL(5,2) DEFAULT 0,
    xep_loai VARCHAR(50),
    trang_thai VARCHAR(20) DEFAULT 'CHUA_TINH' CHECK (trang_thai IN ('CHUA_TINH', 'DA_TINH', 'DA_DUYET')),
    ngay_tinh TIMESTAMP,
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(nguoi_dung_id, thang, nam)
);

-- ===============================================
-- 15. BẢNG LOG HỆ THỐNG
-- ===============================================
CREATE TABLE IF NOT EXISTS log_he_thong (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nguoi_dung_id UUID REFERENCES nguoi_dung(id),
    hanh_dong VARCHAR(100) NOT NULL,
    doi_tuong VARCHAR(100),
    doi_tuong_id UUID,
    mo_ta TEXT,
    ip_address VARCHAR(50),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================================
-- INSERT HỆ SỐ QUY ĐỔI
-- ===============================================
DO $$
DECLARE
    sp_rec RECORD;
    md_rec RECORD;
    v_he_so DECIMAL(10,2);
BEGIN
    -- Lấy tất cả sản phẩm
    FOR sp_rec IN SELECT id, ma_san_pham FROM dm_san_pham WHERE trang_thai = TRUE LOOP
        FOR md_rec IN SELECT id, ma_muc_do FROM dm_muc_do WHERE trang_thai = TRUE AND ma_muc_do != '5' LOOP
            -- Tính hệ số dựa trên sản phẩm và mức độ
            v_he_so := CASE 
                WHEN sp_rec.ma_san_pham = 'SP01' THEN POWER(2, md_rec.ma_muc_do::INT - 1)
                WHEN sp_rec.ma_san_pham = 'SP02' THEN POWER(2, md_rec.ma_muc_do::INT)
                WHEN sp_rec.ma_san_pham = 'SP03' THEN md_rec.ma_muc_do::INT * 1.5
                WHEN sp_rec.ma_san_pham = 'SP04' THEN md_rec.ma_muc_do::INT * 2
                WHEN sp_rec.ma_san_pham = 'SP05' THEN 1
                WHEN sp_rec.ma_san_pham = 'SP06' THEN 1
                WHEN sp_rec.ma_san_pham = 'SP07' THEN md_rec.ma_muc_do::INT * 4
                WHEN sp_rec.ma_san_pham = 'SP08' THEN md_rec.ma_muc_do::INT * 3
                WHEN sp_rec.ma_san_pham = 'SP09' THEN md_rec.ma_muc_do::INT * 2
                WHEN sp_rec.ma_san_pham = 'SP10' THEN 1
                ELSE 1
            END;
            
            INSERT INTO dm_he_so (san_pham_id, muc_do_id, he_so)
            VALUES (sp_rec.id, md_rec.id, v_he_so)
            ON CONFLICT (san_pham_id, muc_do_id) DO NOTHING;
        END LOOP;
    END LOOP;
END $$;

-- ===============================================
-- TẠO TÀI KHOẢN ADMIN VÀ TCCB
-- Mật khẩu mặc định: 123456 (SHA256)
-- ===============================================
INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, la_admin, la_tccb)
VALUES ('admin', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Quản trị hệ thống', TRUE, TRUE)
ON CONFLICT (ma_cong_chuc) DO NOTHING;

-- ===============================================
-- INSERT 548 CÔNG CHỨC TỪ DANH SÁCH EXCEL
-- ===============================================

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0224', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Quốc Hưng', '29/10/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'LDCC'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CCT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0224');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0565', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Ngọc Lợi', '02/9/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'LDCC'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PCCT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0565');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0119', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Tùng Dương', '18/04/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'LDCC'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PCCT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0119');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0479', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Cảnh Thắng', '12/02/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'LDCC'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PCCT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0479');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0097', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Tống Thị Thái Hà', '27/03/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CVP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0097');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0238', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quốc Thịnh', '04/06/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PVP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0238');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0049', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Liên', '11/04/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PVP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0049');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0062', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Kim Oanh', '18/12/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PVP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0062');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0007', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Kim Long', '08/12/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0007');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0450', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Thị Hằng', '22/8/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0450');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0010', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Thị Cẩm Linh', '10/10/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0010');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0013', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Xuân Hương', '20/04/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0013');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0212', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Bích Diệp', '1987-11-25 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0212');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0015', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trịnh Thị Thu', '18/10/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0015');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0012', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thanh Vân 1990', '26/10/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0012');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0592', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thanh Ngân', '1999-11-12 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0592');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0135', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Khánh Ninh', '30/11/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0135');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0394', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lại Thị Hồng Hoa', '22/09/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0394');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0390', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Hồng Quang', '08/08/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0390');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0101', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Vân Anh', '30/01/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0101');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0059', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Thị Thu Trang', '1991-11-14 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0059');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0368', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Quỳnh Trang', '16/02/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0368');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0599', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Duy Bình', '27/9/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0599');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0585', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đình Lộc', '26/03/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0585');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0114', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đức Hân', '10/12/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0114');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0359', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Tuấn 1986', '04/07/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0359');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0020', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mai Đức Tâm', '09/01/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0020');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0029', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thanh Tâm', '1990-03-01 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0029');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0019', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Anh Luận', '24/09/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0019');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0024', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Thanh Huyền', '20/08/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0024');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0026', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Chí Nguyện', '1985-10-08 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0026');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0561', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đồng Thị Kim Thu', '1985-10-17 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0561');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0025', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Tuyết Mai', '14/11/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0025');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0030', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Sĩ', '16/04/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0030');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0371', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Tuấn Duy', '18/10/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0371');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0027', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Thảo', '1992-12-03 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0027');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0477', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Công Điển', '01/01/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0477');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0031', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Lưu', '28/01/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0031');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0028', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Thị Huyền 1980', '1980-05-24 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0028');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0177', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Minh Quý', '1988-08-22 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0177');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0557', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lương Thị Vui', '04/09/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0557');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0558', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Chiến', '06/01/2000',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0558');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0032', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Tuấn Hải', '16/09/1991',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0032');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0610', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Hiên', '26/8/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0610');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0617', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Tạ Văn Khanh', '1981-04-26 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VP'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0617');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0005', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Võ Hồng Chung', '19/10/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'TP'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0005');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0035', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thuý Nga 1978', '26/04/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0035');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0240', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mai Thế Dương', '25/10/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0240');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0350', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Thị Thu Hà', '28/02/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0350');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0036', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Quỳnh Mai', '19/12/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0036');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0312', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Minh Trang', '1991-05-09 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0312');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0322', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phùng Thế Phương', '1984-01-07 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0322');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0211', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Dương Thanh Hà', '07/09/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0211');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0044', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Tạ Thị Hiền', '10/05/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0044');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0042', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Hồng Chinh', '13/12/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0042');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0321', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Quang Huy', '1991-01-13 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0321');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0403', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Khánh Hoàng', '11/09/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0403');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0041', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Duy Phương', '1987-12-12 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0041');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0591', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Thị Hoa', '04/09/1996',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'TCCB'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    TRUE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0591');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0061', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đinh Việt Dũng', '01/08/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'TP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0061');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0227', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Dương', '12/07/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0227');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0129', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Thanh Thuỷ', '15/10/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0129');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0075', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thuý Nga 1973', '26/10/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0075');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0439', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Tiến Đạt', '22/01/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0439');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0052', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Châu Cương', '16/12/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0052');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0078', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trương Văn Quân', '23/04/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0078');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0066', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lý Thị Nhiên', '18/10/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0066');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0621', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Hoàng', '1994-11-14 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0621');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0407', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Sâm', '26/03/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0407');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0584', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Minh Cường', '1995-05-10 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0584');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0589', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Bá Thành', '23/07/2001',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0589');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0552', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thanh Tùng', '23/8/1992',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0552');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0310', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Hằng', '28/04/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0310');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0306', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Đình Toản', '10/12/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0306');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0173', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hữu Tuấn', '1990-05-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0173');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0102', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Dương Hương Giang', '06/09/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0102');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0072', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Hồng', '14/07/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0072');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0490', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Hữu Phong', '15/02/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'NVHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0490');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0452', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Huy Đông', '28/08/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'TP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0452');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0098', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quốc Bình', '28/06/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0098');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0063', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thị Hải Ninh', '20/08/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0063');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0366', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trịnh Ngọc Hoàng Nam', '29/10/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0366');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0100', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Minh Đức', '12/9/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0100');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0262', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thu Hằng', '1990-03-04 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0262');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0446', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Lan Hương 1989', '05/08/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0446');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0594', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Thị Ngọc Hoàn', '05/12/2000',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'QLRR'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0594');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0431', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Quý Hưng', '01/09/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'TP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0431');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0116', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trương Ngọc Quảng', '02/05/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0116');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0105', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Quang Huy', '20/10/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PTP'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0105');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0393', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Quang Trung', '04/12/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0393');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0257', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hà Văn Sơn', '01/12/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0257');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0282', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đặng Viết Thành', '03/09/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0282');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0205', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trương Anh Tuấn', '28/08/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0205');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0115', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Tuyển', '12/08/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0115');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0290', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Văn Nam', '23/07/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0290');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0112', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Thị Huyền 1985', '08/08/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0112');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0586', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vi Trung Hiếu', '24/12/2000',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CNTT'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0586');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0231', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thuý Hà', '14/09/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0231');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0186', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Hanh', '16/09/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0186');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0580', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thế Việt', '10/6/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0580');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0401', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Hào', '26/05/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0401');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0122', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Dương Xuân Lý', '20/12/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0122');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0232', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Ngọc Thạch', '30/09/1964',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0232');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0121', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mạc Tiến Quân', '27/10/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0121');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0228', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Viết Khoa', '12/03/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0228');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0346', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Đình Trung', '21/03/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0346');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0345', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Thọ', '20/11/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0345');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0124', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trương Việt Dũng', '16/04/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0124');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0482', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quang Huy', '26/04/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0482');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0239', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thanh Dương', '26/05/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0239');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0444', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Hiếu', '21/07/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0444');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0284', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đinh Ngọc Thiệu', '07/07/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0284');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0381', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Thu Thảo', '24/08/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0381');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0458', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Nguyên Hoàn', '15/11/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0458');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0395', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Bá An', '1974-08-10 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0395');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0157', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Hải Yến', '08/09/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0157');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0259', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Thị Hòa', '25/10/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0259');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0522', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trịnh Đăng Dung', '1977-04-20 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0522');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0196', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Phòng', '30/10/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0196');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0159', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lưu Thị Loan', '15/05/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0159');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0461', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Sỹ Bình', '17/01/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0461');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0144', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Dương Mạnh Hà', '30/06/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0144');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0492', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Mạnh Hùng', '15/12/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0492');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0365', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đặng Tích Khoa', '21/7/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0365');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0392', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vương Văn Mạnh', '13/11/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0392');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0360', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Hồng Quân', '07/01/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0360');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0464', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Mạnh Hùng 1974', '25/04/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0464');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0266', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Đình Thọ', '03/09/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0266');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0311', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lương Viết Sơn Hà', '28/09/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0311');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0043', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Phạm An Hà', '29/09/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0043');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0086', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Dương Thương', '03/11/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0086');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0093', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Hương', '05/09/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0093');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0087', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đàm Quang Lượng', '18/08/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0087');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0160', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Khanh', '01/06/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0160');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0354', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Mạnh Hà', '3/10/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0354');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0555', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thanh Hồng', '14/01/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0555');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0467', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thu Ngân', '1989-09-20 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0467');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0213', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Vân Trung', '02/09/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0213');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0473', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thị Thanh Vân', '1986-02-09 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0473');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0255', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Việt Thanh', '2/5/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0255');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0278', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Thặng', '20/10/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0278');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0414', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Đức', '11/12/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0414');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0475', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thế Thành', '18/12/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0475');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0562', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hữu Phong', '1988-11-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0562');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0091', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Hoàng Tùng', '31/08/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0091');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0305', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Cao Sơn', '04/07/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0305');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0190', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Duy Khánh', '02/9/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0190');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0208', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thanh Hương', '30/04/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0208');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0288', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trịnh Quang Khoa', '16/05/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0288');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0265', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phùng Văn Chuyển', '14/07/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0265');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0201', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Nhung', '27/09/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0201');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0443', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Hồng Thắm', '15/11/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0443');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0014', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Đình Cương', '25/11/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0014');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0582', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Đức Long', '1983-08-23 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0582');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0554', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Tùng Dương', '08/01/1997',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0554');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0498', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Tuấn Minh', '1976-05-27 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0498');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0313', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Công Hoàn', '9/3/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0313');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0143', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Loan', '18/02/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0143');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0127', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Chí Thái', '19/01/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0127');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0107', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Anh Tuấn 1981', '05/05/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0107');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0349', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Thực', '23/09/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0349');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0287', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Vĩnh Hương', '10/09/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0287');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0483', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đức Tuệ 1985', '07/12/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0483');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0281', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Hằng', '30/06/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0281');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0595', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Khánh Linh', '08/05/1999',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0595');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0597', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Nguyên Linh', '28/04/2001',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0597');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0330', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Thanh Nguyên', '15/05/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0330');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0500', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đình Thảo', '26/7/1991',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0500');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0178', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Quang Long', '27/08/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0178');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0183', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thái Hưng', '08/12/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0183');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0181', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Thêu', '10/11/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0181');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0175', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Hải', '22/12/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0175');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0182', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Thị Thương', '1992-11-20 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0182');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0184', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Đạt', '1978-12-23 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0184');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0615', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Trung Hiếu', '1992-09-03 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0615');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0179', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Hồng Thảo', '08/09/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HGAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0179');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0073', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phùng Thị Nguyên Hạnh', '22/05/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0073');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0084', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Minh', '07/01/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0084');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0106', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quang Chinh', '15/08/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0106');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0454', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Quang Tùng', '23/02/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0454');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0241', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Việt Dũng', '08/08/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0241');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0405', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Việt Đức', '04/09/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0405');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0011', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thu Trang', '22/11/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0011');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0054', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Dũng', '4/8/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0054');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0294', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Đức', '18/07/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0294');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0197', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Nghĩa Long', '16/06/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0197');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0352', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hồ Văn Hoàn', '15/05/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0352');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0363', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vương Kiên Trung', '02/07/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0363');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0202', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hồng Trường', '17/10/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0202');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0167', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Thế An', '07/01/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0167');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0417', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Vũ Hải', '11/06/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0417');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0251', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Khắc Trung', '19/10/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0251');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0411', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Huy Hoàng', '28/08/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0411');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0203', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Mạnh Hùng', '01/02/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0203');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0068', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Mai Anh', '1991-08-29 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0068');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0449', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Bích Diệp', '12/6/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0449');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0466', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Trung Kiên', '13/8/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0466');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0263', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Trang', '29/10/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0263');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0598', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thị Thu Hiền 1989', '20/9/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0598');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0546', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đặng Hoàng Sơn', '19/6/1996',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0546');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0550', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Huyên', '22/9/1994',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0550');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0295', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thế Tuấn', '08/11/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0295');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0593', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Duy Tài', '31/08/2001',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0593');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0588', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vương Thị Thoa', '03/7/1991',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0588');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0221', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trương Thị Bình', '14/05/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0221');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0220', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Viết Cường 1971', '26/4/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0220');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0487', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Hiến', '14/04/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0487');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0420', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Ngọc Hà', '28/05/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0420');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0222', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Tùng', '4/7/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0222');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ - 0223', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hà Thị Kim Thanh', '21/11/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ - 0223');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0604', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Mai Anh', '18/4/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0604');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0603', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Khánh Chi', '1978-01-10 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0603');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0469', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Lê Thế Anh', '22/12/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0469');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0533', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Văn Hiệu', '07/09/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0533');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0602', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Anh Dũng', '2000-10-22 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0602');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0619', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Quốc Văn', '1987-06-05 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'CPHA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0619');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0400', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Xuân Hiền', '23/11/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0400');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0034', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Ngọc Linh', '26/11/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0034');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0083', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Minh', '28/09/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0083');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0074', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Hồng Hải', '20/04/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0074');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0065', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Trung', '04/10/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0065');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0039', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Minh Tuấn', '08/02/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0039');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0342', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Hồng Chuyên', '30/07/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0342');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0434', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Thị Mỳ', '14/04/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0434');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0120', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vương Trọng Dũng', '10/10/1964',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0120');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0079', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đình Phúc', '11/12/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0079');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0456', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Bình Minh', '02/02/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0456');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0008', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Tiến Dũng', '04/12/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0008');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0237', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thanh Quang 1975', '10/07/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0237');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0406', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Anh Tuấn', '19/07/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0406');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0484', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Trung Dũng', '08/12/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0484');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0191', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Bá Dương', '20/7/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0191');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0125', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hà Quang Huy', '29/11/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0125');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0192', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Anh Tuấn', '10/11/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0192');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0145', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Bích Phong', '04/03/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0145');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0193', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Minh Trung', '10/09/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0193');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0110', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thuý Hà', '21/04/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0110');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0438', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Tiến Dũng 1981', '07/02/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0438');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0457', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Việt', '01/02/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0457');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0485', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Vinh', '22/11/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0485');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0130', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Duy Hưng', '17/06/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0130');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0435', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Ngọc Thanh', '12/06/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0435');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0242', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thu Hương', '12/8/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0242');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0243', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Chương', '20/09/1964',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0243');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0448', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Hiền', '15/09/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0448');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0077', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Vững', '25/01/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0077');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0308', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Phương Thanh', '13/8/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0308');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0152', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Hoà', '26/03/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0152');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0154', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Thị Hà', '30/07/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0154');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0139', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đức Tuệ 1971', '03/01/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0139');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0496', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Văn Tám', '08/05/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0496');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0069', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Thị Hường', '20/09/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0069');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0292', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Hữu Việt', '11/04/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0292');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0209', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Quỳnh Trang', '15/09/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0209');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0474', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lưu Đình Hải', '24/05/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0474');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0168', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Thuỳ Linh', '24/11/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0168');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0194', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Minh Hoàn', '11/10/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0194');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0245', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Thuý Hằng', '02/02/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0245');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0409', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Tuấn Phong', '21/07/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0409');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0521', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Khuất Duy Phiến', '06/13/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0521');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0307', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thạch Dũng', '06/11/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0307');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0207', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thanh Quang 1970', '06/05/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0207');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0447', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Trọng Nghĩa', '07/12/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0447');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0579', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hoài Linh', '1985-08-25 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0579');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0058', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Hồng Vân', '03/06/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0058');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0166', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Thị Ngọc Thuỷ', '10/12/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0166');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0613', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Xuân Trà', '1993-09-13 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0613');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0495', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Tuyển', '20/10/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0495');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0272', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đức Linh', '1987-03-12 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0272');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0081', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Mạnh Tú', '14/03/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0081');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0445', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lý Trần Hùng', '26/10/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0445');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0103', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Trọng Khoa', '1985-02-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0103');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0204', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Thế Lầu', '16/05/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0204');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0138', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Văn Thoại', '15/10/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0138');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0155', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Quang Anh', '17/5/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0155');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0113', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quốc Anh', '17/09/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0113');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0109', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thị Thu Hiền', '30/06/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0109');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0517', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quang Trung', '20/8/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0517');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0267', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thị Minh', '06/07/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0267');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0053', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Văn Khởi', '18/8/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0053');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0497', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Khánh', '19/08/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0497');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0488', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Hiền', '30/11/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0488');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0512', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Phúc Thành', '29/06/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0512');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0080', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mai Xuân Sơn', '20/08/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0080');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0085', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Tuấn Anh', '01/03/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0085');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0137', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Cao Mười', '05/02/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0137');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0057', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trương Hoàng Lâm', '03/04/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0057');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0553', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Thân Lê Quỳnh Trang', '28/12/1998',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0553');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0038', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mạc Nguyễn Tú Mai', '25/07/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0038');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0070', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thu Hương', '06/06/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0070');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0215', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Hoa', '1985-11-23 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0215');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0357', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Hải Sơn', '28/02/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0357');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0549', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hứa Hà Lê', '13/9/1994',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0549');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0351', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hà Ngọc Sơn', '29/03/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0351');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0513', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Tiến Vinh', '30/05/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0513');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0355', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đặng Văn Thuấn', '01/09/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0355');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0545', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Thị Bích Diệp', '22/9/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0545');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0151', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Thị Thanh Bình', '22/01/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0151');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0134', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Văn Tiến', '04/05/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0134');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0279', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Thành', '08/02/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0279');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0486', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Thu Hà', '24/06/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0486');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0472', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Lâm', '21/04/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0472');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0551', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Thắng', '27/11/1998',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0551');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0051', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Vân Anh', '26/08/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0051');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0141', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Đình Hoàng', '20/03/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0141');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0076', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Văn Cương', '25/12/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0076');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0459', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Quang Long', '10/03/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0459');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0206', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Công Toàn', '09/11/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0206');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0046', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Thanh Huyền', '1990-08-30 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0046');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0064', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đàm Quang Cường', '07/11/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0064');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0094', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lưu Hải Hà', '11/04/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0094');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0462', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Tuấn 1966', '14/08/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0462');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0055', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Tuyết Hồng', '30/11/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0055');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0463', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Định', '31/12/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0463');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0547', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Ngọc Dũng', '16/11/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0547');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0162', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thanh Dương', '25/01/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0162');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0040', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Việt Toàn', '1977-06-05 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0040');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0410', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Duy Hưng', '03/06/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0410');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0468', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Huy Quỳnh', '1973-12-04 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0468');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0560', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Thu Thuỷ', '01/10/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0560');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0476', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Toản', '08/10/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0476');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0465', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Quốc Kiên', '26/01/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0465');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0611', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Mạnh', '21/11/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0611');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0056', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Trọng Lượng', '14/09/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0056');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0133', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thịnh Trường', '21/05/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0133');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0520', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nghiêm Xuân Sơn', '10/04/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0520');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0131', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thuý Chinh', '12/10/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0131');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0493', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Hùng', '25/01/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0493');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0442', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thế Trường', '16/10/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0442');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0324', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Đức Kiên 1991', '28/04/1991',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0324');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0323', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Anh Tuấn 1982', '17/10/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0323');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0325', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Trọng Quỳnh', '1991-12-09 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0325');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0326', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Kiên', '1986-08-05 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0326');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0327', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Hồng Quang', '30/12/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0327');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0332', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thị Phương', '1983-03-02 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0332');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0331', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thu Hường', '24/07/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0331');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0334', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Hưng', '15/11/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0334');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0335', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Quang Quý', '23/07/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0335');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0529', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đức Quang', '06/05/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0529');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0556', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Xuê', '1987-03-27 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0556');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0502', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Cao Cường', '07/04/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0502');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0333', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Anh', '16/08/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0333');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0336', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Hồng Hải', '25/8/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0336');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0337', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Trường Giang', '1987-01-03 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0337');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0608', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Xuân Anh', '16/01/1992',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0608');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0527', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Bình Dương', '15/06/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0527');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0176', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Hoàn 1995', '1995-10-07 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0176');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0616', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Yến', '1983-12-01 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0616');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0618', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Công Duy', '1995-01-23 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0618');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0017', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Xuân Tùng', '11/07/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'MCAI'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0017');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0375', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đậu Hùng Dương', '06/01/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0375');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0048', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hồng Lâm', '26/07/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0048');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0581', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Thế Thăng', '1978-07-12 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0581');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0380', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Vinh Quang', '07/10/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0380');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0123', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Thị Hồng', '12/11/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0123');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0436', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Công Hùng', '04/06/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0436');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0128', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vi Thiệu Hùng', '21/09/1964',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0128');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0188', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Trí Dũng', '18/05/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0188');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0451', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Nguyệt', '26/03/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0451');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0045', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Ngọc Diệp', '06/05/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0045');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0171', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Linh Chi', '05/07/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0171');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0358', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mai Viết Long', '15/12/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0358');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0200', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Công Thịnh', '04/09/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0200');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0383', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đinh Bá Sơn', '10/07/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0383');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0163', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Xuân Đoàn', '07/03/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0163');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0489', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Trung Kiên 1965', '12/03/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0489');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0271', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Quang Hưng', '25/12/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0271');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0050', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Thuỷ', '18/05/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0050');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0088', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Mạnh Hùng', '11/07/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0088');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0622', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đỗ Quang Long', '2001-01-16 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0622');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0386', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Hồng Vân', '21/09/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0386');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0348', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bế Sỹ Tâm', '23/05/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0348');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0364', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đinh Văn Long', '13/04/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0364');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0158', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Doãn Việt Hùng', '12/02/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0158');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0153', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Trường Sơn', '16/07/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0153');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0440', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lưu Thị Sen', '20/04/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0440');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0293', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lương Ngọc Thành', '05/05/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0293');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0372', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Chu Thị Tiên', '25/11/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0372');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0373', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Duy Huy', '1991-10-30 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0373');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0370', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Tỉnh', '1982-08-31 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0370');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0021', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Cường', '29/05/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0021');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0374', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Xuân Tùng', '1971-10-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0374');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0369', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Viết Cường 1988', '1988-08-14 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0369');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0606', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Duy Nam', '1999-06-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0606');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0607', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thị Tình', '25/5/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0607');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0600', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Chu Văn Hà', '23/8/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'HMO'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0600');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0033', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Mạnh Tùng', '31/07/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0033');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0006', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quang Hưng', '17/03/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0006');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0453', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đức Hải', '07/05/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0453');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0455', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Chính Đại', '19/08/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0455');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0343', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quang Tùng', '28/02/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0343');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0388', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Thế Anh', '1976-01-06 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0388');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0298', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Lan Hương 1987', '1987-12-26 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0298');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0494', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Chu Thanh Huệ', '1986-04-28 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0494');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0146', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Việt Hưng', '09/11/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0146');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0147', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Mạnh Hùng', '02/01/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0147');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0516', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hà Văn Kiểu', '23/09/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0516');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0300', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đình Hoan', '1980-06-28 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0300');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0249', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Hoàng', '06/01/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0249');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0247', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Minh Nguyệt', '01/04/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0247');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0320', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Trung Kiên 1989', '1989-11-05 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0320');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0108', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Văn Chung', '15/06/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0108');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0398', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Công Mạnh', '18/01/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0398');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0397', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thúy', '08/9/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0397');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0399', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Tuyên', '1984-11-10 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'BPS'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0399');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0082', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đức Dũng', '05/09/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0082');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0480', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Biên Hoà', '29/07/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0480');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0187', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đình Hiến', '20/01/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0187');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0470', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thanh Bình', '02/05/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0470');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0189', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đỗ Chức', '25/02/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0189');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0339', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Hồng Lâm', '01/03/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0339');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0258', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thanh Xuân', '28/01/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0258');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0296', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Hà', '02/07/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0296');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0210', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Hùng', '26/10/1966',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0210');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0096', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Tiến Nam', '22/10/1985',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0096');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0441', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Dũng Hà', '03/11/1991',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0441');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0253', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lương Thị Hằng', '04/02/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0253');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0347', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Tạ Quang Tư', '01/01/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0347');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0071', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Nam', '10/11/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0071');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0016', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Ngọc Sơn', '1990-08-05 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0016');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0416', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đình Quang', '13/06/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0416');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0214', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Hoàng Giang', '1990-10-26 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0214');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0301', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Hữu Trung', '22/09/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0301');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0172', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Quốc Phong', '21/01/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0172');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0199', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Anh Tuấn 1984', '07/08/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0199');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0254', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Bá Huân', '15/04/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0254');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0142', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Minh Tuấn', '15/07/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0142');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0385', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Văn Phương', '20/07/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0385');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0314', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Nhân', '22/10/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0314');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0090', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Anh Tuấn 1972', '10/03/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0090');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0277', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Nam', '05/12/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0277');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0563', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Cù Hoàng Việt', '02/02/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0563');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0233', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Trung Kiên1977', '20/01/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0233');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0302', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Ngọc Dương', '24/11/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0302');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0344', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Xuân Lâm', '17/07/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0344');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0510', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Nghĩa Hoằng', '18/06/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0510');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0501', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mạc Văn Hiểu', '12/02/1973',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0501');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0528', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Công Vương', '03/04/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0528');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0219', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Văn Quân', '1984-05-12 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0219');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0499', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Hiếu', '02/04/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0499');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0532', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Ngọc Tuyên', '18/10/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0532');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0537', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Cường', '1984-12-29 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0537');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0180', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Thị Hương', '21/8/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0180');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0535', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trương Quốc Huy', '28/10/1995',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0535');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0530', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Lương Quyền', '30/5/1988',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0530');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0538', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Mạnh Trung', '1985-10-04 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0538');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0539', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Đình Duẩn', '1981-06-20 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0539');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0174', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Tân', '25/09/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0174');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0429', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đoàn Việt Hùng', '1964-01-09 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0429');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0430', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Thị Thu Hoài', '1974-07-04 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0430');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0534', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Ngọc Hải', '28/10/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0534');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0601', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đậu Anh Tuấn', '20/8/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0601');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0503', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Bản', '13/12/1998',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0503');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0505', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần  Văn Giảng', '04/03/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0505');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0531', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Trọng Đạt', '24/10/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'VGIA'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0531');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0185', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Xuân Hiệp', '28/10/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0185');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0229', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thanh Long', '08/07/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0229');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0118', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Văn Kiên', '19/09/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0118');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0433', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Mạnh Toàn', '20/04/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0433');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0126', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Thanh Hải', '28/08/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0126');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0236', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Trọng Nghĩa', '29/11/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0236');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0437', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Duy Bách', '20/06/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0437');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0264', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Hải', '15/08/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0264');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0244', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Quý', '19/12/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0244');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0273', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Xuân Khánh', '31/08/1987',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0273');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0291', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hồ Thị Hà', '25/7/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0291');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0378', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Chu Minh Phong', '19/02/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0378');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0037', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Quý Đức', '1977-04-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0037');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0169', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đinh Ngọc Phượng Hà', '21/11/1979',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0169');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0384', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Mạnh Hùng 1970', '14/09/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0384');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0318', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Duy Khang', '1990-06-04 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0318');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0009', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thanh Vân 1989', '05/09/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0009');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0303', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thanh Hảo', '27/06/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0303');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0583', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Mai Hoàng Anh', '11/4/1992',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0583');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0590', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Đức Tuấn', '20/09/2000',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0590');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0596', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Ngọc Mai', '02/01/2001',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'PTKTSTQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0596');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0338', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hoàng Tuân', '19/11/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'DT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0338');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0506', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Kiều Văn Ninh', '03/08/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0506');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0481', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Hải Sơn', '17/11/1969',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0481');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0471', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thế Thiện', '04/04/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0471');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0507', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thanh Bình', '23/06/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0507');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0226', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Hà Phong', '27/03/1965',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0226');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0620', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Văn Vinh', '1980-10-10 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'PDT'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0620');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0261', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Mạnh Cường 1970', '03/01/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0261');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0095', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thành Luân', '1984-08-29 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0095');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0161', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thơm', '14/12/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0161');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0316', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Cao Văn Phúc', '1974-08-09 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0316');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0491', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Dũng', '1985-06-04 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0491');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0092', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Ngọc Thái', '20/08/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0092');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0317', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hoàng Sâm', '1972-06-27 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0317');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0587', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hồng Ngọc', '18/07/2000',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0587');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0408', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Tuyên', '23/09/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0408');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0250', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Minh Tuấn', '21/10/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0250');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0319', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Hùng Sơn', '1986-10-25 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0319');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0195', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Hùng Cường', '09/01/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0195');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0315', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trịnh Trọng Thái', '1983-02-10 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0315');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0508', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Xuân Giáp', '13/09/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0508');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0230', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Quang Vinh', '05/01/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0230');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0140', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Sưởng', '1972-02-07 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0140');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0382', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Khiêm', '16/05/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0382');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0248', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Tiến ánh', '15/11/1968',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0248');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0304', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Thị Hậu', '14/07/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0304');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0309', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đặng Anh Tuấn', '12/04/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0309');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0275', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Minh Sơn', '04/07/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0275');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0252', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Xuân Huynh', '20/04/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0252');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0156', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Hồng Ngọc', '18/11/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0156');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0612', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Tiến Mạnh', '1981-10-27 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0612');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0234', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Hồng Phúc', '11/02/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0234');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0509', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đinh Tiến Minh', '19/01/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0509');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0341', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đặng Ngọc Thanh', '02/06/1971',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0341');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0511', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Chí Cường 1981', '25/11/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0511');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0198', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Xuân Thịnh', '02/03/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0198');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0268', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Doãn Hiệp', '19/08/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0268');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0514', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thị Thanh Huyền', '1977-12-22 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0514');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0515', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Thu Hiền', '15/02/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0515');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0235', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Hồng Hải 1978', '13/03/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0235');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0067', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Cao Thị Hồng Hạnh', '16/08/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0067');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0111', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lê Văn Thắng', '12/03/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0111');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0412', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Khoa', '09/07/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0412');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0246', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hà Đức Hùng', '1986-11-02 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0246');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0536', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quang Anh', '1987-10-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0536');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0540', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đào Nam Chung', '1978-11-11 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0540');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0564', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Hoàng Trọng Quý', '1982-08-04 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0564');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0299', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thu Huế', '05/07/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0299');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0362', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Quốc Bình', '12/06/1972',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'CC'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0362');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0022', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Đỗ Hoàng Dương', '03/07/2000',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0022');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0526', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Đình Tường', '26/10/1982',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0526');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0524', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Viết Tiến', '24/09/1970',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0524');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0523', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lưu Chí Công', '1976-08-10 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0523');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0426', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Quang Sơn', '16/04/1983',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0426');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0328', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thế Hùng', '21/04/1967',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0328');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0422', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Thành Công', '29/03/1989',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0422');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0423', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Đức', '17/02/1980',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0423');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0421', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Đình Thương', '14/02/1975',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0421');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0559', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Nguyễn Văn Đông', '02/10/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0559');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0396', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Giáp Văn Việt', '15/08/1986',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0396');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0525', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Lâm', '15/05/1974',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0525');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0018', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Bùi Quang Tiến', '09/06/1977',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0018');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0504', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phan Văn Quang', '06/12/1990',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0504');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0609', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Tài', '27/8/2002',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0609');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0614', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Thị Gấm', '1984-11-05 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0614');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0424', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Đại Nghĩa', '27/08/1976',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0424');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0218', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Huy Toàn', '28/06/1981',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0218');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0419', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Ngô Đình Cường', '12/05/1984',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0419');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0418', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Lý Ngọc Đàm', '30/05/1978',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0418');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0329', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Phạm Văn Ngọc', '1981-12-16 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0329');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0427', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Vũ Văn Khá', '1988-01-05 00:00:00',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0427');

INSERT INTO nguoi_dung (ma_cong_chuc, mat_khau, ho_ten, nam_sinh, don_vi_id, chuc_vu_id, la_tccb)
SELECT '20ZZ-0544', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'Trần Thanh Tùng', '20/05/1992',
    (SELECT id FROM dm_don_vi WHERE ma_don_vi = 'KSHQ'),
    (SELECT id FROM dm_chuc_vu WHERE ma_chuc_vu = 'HD'),
    FALSE
WHERE NOT EXISTS (SELECT 1 FROM nguoi_dung WHERE ma_cong_chuc = '20ZZ-0544');