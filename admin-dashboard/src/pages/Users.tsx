import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Search, Ban, CheckCircle, Smartphone, Plus, Download } from 'lucide-react';
import api from '../lib/axios';
import { Badge } from '../components/ui/Badge';
import { UserModal } from '../components/users/UserModal';

interface User {
    id: string;
    email: string;
    name: string | null;
    role: string;
    isActive: boolean;
    createdAt: string;
    _count: {
        routers: number;
    };
    subscription?: {
        status: string;
        expiresAt: string;
        plan: { name: string } | null;
    } | null;
}

export function UsersPage() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [page, setPage] = useState(1);
    const [totalPages, setTotalPages] = useState(1);
    const [isModalOpen, setIsModalOpen] = useState(false);

    const fetchUsers = async () => {
        setLoading(true);
        try {
            const { data } = await api.get('/admin/users', {
                params: { page, limit: 10, search }
            });
            setUsers(data.data);
            setTotalPages(data.meta.lastPage);
        } catch (error) {
            console.error('Failed to fetch users', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const handler = setTimeout(() => {
            fetchUsers();
        }, 300); // Debounce search
        return () => clearTimeout(handler);
    }, [page, search]);

    const toggleStatus = async (id: string, currentStatus: boolean) => {
        if (!window.confirm(`Are you sure you want to ${currentStatus ? 'ban' : 'activate'} this user?`)) return;

        try {
            await api.patch(`/admin/users/${id}/status`, { isActive: !currentStatus });
            fetchUsers(); // Refresh list
        } catch (error) {
            alert('Failed to update status');
        }
    };

    const handleCreateUser = async (data: any) => {
        try {
            await api.post('/admin/users', data);
            fetchUsers();
        } catch (error: any) {
            alert(error.response?.data?.message || 'Failed to create user');
            throw error;
        }
    };

    const handleExport = async () => {
        try {
            const response = await api.get('/admin/users/export', { responseType: 'blob' });
            const url = window.URL.createObjectURL(new Blob([response.data]));
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', `users_${new Date().toISOString().slice(0, 10)}.csv`);
            document.body.appendChild(link);
            link.click();
            link.remove();
        } catch (error) {
            alert('Failed to export users');
        }
    };

    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800">User Management</h1>
                <div className="flex space-x-4">
                    <div className="relative">
                        <input
                            type="text"
                            placeholder="Search users..."
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            className="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none w-64"
                        />
                        <Search className="w-5 h-5 text-gray-400 absolute left-3 top-2.5" />
                    </div>
                    <button
                        onClick={handleExport}
                        className="flex items-center px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                    >
                        <Download className="w-5 h-5 mr-2" />
                        Export CSV
                    </button>
                    <button
                        onClick={() => setIsModalOpen(true)}
                        className="flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 transition-colors"
                    >
                        <Plus className="w-5 h-5 mr-2" />
                        Create User
                    </button>
                </div>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <div className="overflow-x-auto">
                    <table className="w-full text-left">
                        <thead className="bg-gray-50 border-b border-gray-100">
                            <tr>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">User</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Role</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Status</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Routers</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Joined</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {loading ? (
                                <tr>
                                    <td colSpan={6} className="px-6 py-8 text-center text-gray-500">Loading...</td>
                                </tr>
                            ) : users.length === 0 ? (
                                <tr>
                                    <td colSpan={6} className="px-6 py-8 text-center text-gray-500">No users found</td>
                                </tr>
                            ) : (
                                users.map((user) => (
                                    <tr key={user.id} className="hover:bg-gray-50 transition-colors">
                                        <td className="px-6 py-4">
                                            <div className="font-medium text-gray-900 hover:text-indigo-600 cursor-pointer transition-colors">
                                                <Link to={`/users/${user.id}`}>{user.name || 'Unnamed'}</Link>
                                            </div>
                                            <div className="text-sm text-gray-500">{user.email}</div>
                                        </td>
                                        <td className="px-6 py-4">
                                            <Badge variant="info">{user.role}</Badge>
                                        </td>
                                        <td className="px-6 py-4">
                                            {!user.isActive ? (
                                                <Badge variant="error">Banned</Badge>
                                            ) : user.subscription?.status === 'ACTIVE' && new Date(user.subscription.expiresAt) > new Date() ? (
                                                <div className="flex flex-col gap-1">
                                                    <Badge variant="success">Active</Badge>
                                                    <span className="text-xs text-gray-500">{user.subscription.plan?.name || 'Plan'}</span>
                                                </div>
                                            ) : (
                                                <Badge variant="warning">No Subscription</Badge>
                                            )}
                                        </td>
                                        <td className="px-6 py-4">
                                            <div className="flex items-center text-gray-600">
                                                <Smartphone className="w-4 h-4 mr-1 text-gray-400" />
                                                {user._count.routers}
                                            </div>
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-500">
                                            {new Date(user.createdAt).toLocaleDateString()}
                                        </td>
                                        <td className="px-6 py-4 text-right">
                                            <button
                                                onClick={() => toggleStatus(user.id, user.isActive)}
                                                className={`p-2 rounded-lg hover:bg-gray-100 transition-colors ${user.isActive ? 'text-red-600' : 'text-green-600'}`}
                                                title={user.isActive ? 'Ban User' : 'Activate User'}
                                            >
                                                {user.isActive ? <Ban className="w-4 h-4" /> : <CheckCircle className="w-4 h-4" />}
                                            </button>
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>

                {/* Pagination */}
                <div className="px-6 py-4 border-t border-gray-100 flex justify-between items-center">
                    <span className="text-sm text-gray-500">
                        Page {page} of {totalPages}
                    </span>
                    <div className="flex space-x-2">
                        <button
                            disabled={page === 1}
                            onClick={() => setPage(p => Math.max(1, p - 1))}
                            className="px-3 py-1 text-sm border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-50"
                        >
                            Previous
                        </button>
                        <button
                            disabled={page === totalPages}
                            onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                            className="px-3 py-1 text-sm border border-gray-300 rounded hover:bg-gray-50 disabled:opacity-50"
                        >
                            Next
                        </button>
                    </div>
                </div>
            </div>
            <UserModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onSubmit={handleCreateUser}
            />
        </div>
    );
}
