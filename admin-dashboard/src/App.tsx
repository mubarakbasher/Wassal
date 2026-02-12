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

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const token = localStorage.getItem('admin_token');
  if (!token) {
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
          <Route path="users" element={<UsersPage />} />
          <Route path="users/:id" element={<UserDetailsPage />} />
          <Route path="subscriptions" element={<SubscriptionsPage />} />
          <Route path="system" element={<SystemPage />} />
          <Route path="payments" element={<PaymentsPage />} />
          <Route path="settings" element={<SettingsPage />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
