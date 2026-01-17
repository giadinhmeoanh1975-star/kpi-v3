import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { NguoiDung, DonVi, ChucVu, SanPham, MucDo, HeSo, LanhDaoPhuTrach } from '../types';
import { authApi, danhMucApi } from '../api';

interface UserWithInfo extends NguoiDung {
  cap_lanh_dao: number;
  co_the_phe_duyet: boolean;
  don_vi_ten: string;
  chuc_vu_ten: string;
}

interface AuthState {
  token: string | null;
  user: UserWithInfo | null;
  isAuthenticated: boolean;
  login: (ma_cong_chuc: string, mat_khau: string) => Promise<void>;
  logout: () => void;
  refreshUser: () => Promise<void>;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      token: null,
      user: null,
      isAuthenticated: false,

      login: async (ma_cong_chuc: string, mat_khau: string) => {
        const response = await authApi.login(ma_cong_chuc, mat_khau);
        localStorage.setItem('token', response.access_token);
        set({
          token: response.access_token,
          user: response.user,
          isAuthenticated: true,
        });
      },

      logout: () => {
        localStorage.removeItem('token');
        set({
          token: null,
          user: null,
          isAuthenticated: false,
        });
      },

      refreshUser: async () => {
        try {
          const user = await authApi.me();
          set({ user });
        } catch {
          get().logout();
        }
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ token: state.token, user: state.user, isAuthenticated: state.isAuthenticated }),
    }
  )
);

interface DanhMucState {
  donVi: DonVi[];
  chucVu: ChucVu[];
  sanPham: SanPham[];
  mucDo: MucDo[];
  heSo: HeSo[];
  lanhDaoPheduyet: LanhDaoPhuTrach[];
  loading: boolean;
  loaded: boolean;
  fetchAll: () => Promise<void>;
  getHeSo: (san_pham_id: number, muc_do_id: number) => number;
}

export const useDanhMucStore = create<DanhMucState>((set, get) => ({
  donVi: [],
  chucVu: [],
  sanPham: [],
  mucDo: [],
  heSo: [],
  lanhDaoPheduyet: [],
  loading: false,
  loaded: false,

  fetchAll: async () => {
    if (get().loaded || get().loading) return;
    set({ loading: true });
    try {
      const [donVi, chucVu, sanPham, mucDo, heSo, lanhDaoPheduyet] = await Promise.all([
        danhMucApi.getDonVi(),
        danhMucApi.getChucVu(),
        danhMucApi.getSanPham(),
        danhMucApi.getMucDo(),
        danhMucApi.getHeSo(),
        danhMucApi.getLanhDaoPheduyet().catch(() => []),
      ]);
      set({ donVi, chucVu, sanPham, mucDo, heSo, lanhDaoPheduyet, loaded: true });
    } finally {
      set({ loading: false });
    }
  },

  getHeSo: (san_pham_id: number, muc_do_id: number) => {
    const found = get().heSo.find(
      (h) => h.san_pham_id === san_pham_id && h.muc_do_id === muc_do_id
    );
    return found?.he_so ?? 1;
  },
}));

interface AppState {
  currentMonth: number;
  currentYear: number;
  setMonth: (month: number) => void;
  setYear: (year: number) => void;
  setMonthYear: (month: number, year: number) => void;
}

export const useAppStore = create<AppState>((set) => ({
  currentMonth: new Date().getMonth() + 1,
  currentYear: new Date().getFullYear(),
  setMonth: (month) => set({ currentMonth: month }),
  setYear: (year) => set({ currentYear: year }),
  setMonthYear: (month, year) => set({ currentMonth: month, currentYear: year }),
}));

interface NotificationState {
  notifications: Array<{
    id: string;
    type: 'success' | 'error' | 'info' | 'warning';
    message: string;
  }>;
  addNotification: (type: 'success' | 'error' | 'info' | 'warning', message: string) => void;
  removeNotification: (id: string) => void;
}

export const useNotificationStore = create<NotificationState>((set) => ({
  notifications: [],
  addNotification: (type, message) => {
    const id = Date.now().toString();
    set((state) => ({
      notifications: [...state.notifications, { id, type, message }],
    }));
    setTimeout(() => {
      set((state) => ({
        notifications: state.notifications.filter((n) => n.id !== id),
      }));
    }, 5000);
  },
  removeNotification: (id) =>
    set((state) => ({
      notifications: state.notifications.filter((n) => n.id !== id),
    })),
}));
