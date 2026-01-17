import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store';
import { Button, Input, Card } from '../components';
import { ApiError } from '../api';

export const LoginPage: React.FC = () => {
  const navigate = useNavigate();
  const { login } = useAuthStore();
  const [maCongChuc, setMaCongChuc] = useState('');
  const [matKhau, setMatKhau] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      await login(maCongChuc, matKhau);
      navigate('/');
    } catch (err) {
      if (err instanceof ApiError) {
        setError(err.message);
      } else {
        setError('Đã xảy ra lỗi. Vui lòng thử lại.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-500 to-blue-700 py-12 px-4">
      <Card className="w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-2xl font-bold text-gray-900">KPI Management System</h1>
          <p className="mt-2 text-sm text-gray-600">Chi cục Hải quan Khu vực VIII</p>
          <p className="mt-1 text-xs text-gray-500">Phiên bản 3.0</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          {error && (
            <div className="p-3 text-sm text-red-700 bg-red-100 rounded-lg">
              {error}
            </div>
          )}

          <Input
            label="Mã công chức"
            type="text"
            value={maCongChuc}
            onChange={(e) => setMaCongChuc(e.target.value)}
            placeholder="Nhập mã công chức"
            required
            autoFocus
          />

          <Input
            label="Mật khẩu"
            type="password"
            value={matKhau}
            onChange={(e) => setMatKhau(e.target.value)}
            placeholder="Nhập mật khẩu"
            required
          />

          <Button type="submit" className="w-full" loading={loading}>
            Đăng nhập
          </Button>
        </form>

        <div className="mt-6 text-center text-sm text-gray-500">
          <p>Mật khẩu mặc định: <strong>123456</strong></p>
          <p className="mt-1">Liên hệ TCCB nếu quên mật khẩu</p>
        </div>
      </Card>
    </div>
  );
};
