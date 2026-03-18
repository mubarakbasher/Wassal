import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { DashboardLayout } from './components/layout/DashboardLayout';
import { Login } from './pages/Login';
import { Dashboard } from './pages/Dashboard';
import { UsersPage } from './pages/Users';
import { UserDetailsPage } from './pages/UserDetails';
import { SubscriptionsPage } from './pages/Subscriptions';
import { SystemPage } from './pages/System';
import { PaymentsPage } from './pages/Payments';
import { SettingsPage } from './pages/Settings';
import { RoutersPage } from './pages/Routers';
import { VouchersPage } from './pages/Vouchers';
import { MessagesPage } from './pages/Messages';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  // Auth token is stored in httpOnly cookie (not accessible from JS).
  // We use a flag + stored user info for client-side routing.
  // If the cookie is expired/invalid, the server returns 401 and the
  // axios interceptor redirects to /login.
  const isLoggedIn = localStorage.getItem('admin_logged_in') === 'true'
    || localStorage.getItem('admin_token') !== null; // backward compat
  if (!isLoggedIn) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />

        <Route path="/" element={
          <ProtectedRoute>
            <DashboardLayout />
          </ProtectedRoute>
        }>
          <Route index element={<Dashboard />} />
          <Route path="routers" element={<RoutersPage />} />
          <Route path="vouchers" element={<VouchersPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="users/:id" element={<UserDetailsPage />} />
          <Route path="subscriptions" element={<SubscriptionsPage />} />
          <Route path="system" element={<SystemPage />} />
          <Route path="payments" element={<PaymentsPage />} />
          <Route path="messages" element={<MessagesPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
