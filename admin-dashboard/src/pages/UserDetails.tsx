import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, Smartphone, CreditCard, Activity, Calendar, Plus, Ban, Trash2, Wifi, WifiOff } from 'lucide-react';
import api from '../lib/axios';
import { Badge } from '../components/ui/Badge';
import { ManualSubscriptionModal } from '../components/subscriptions/ManualSubscriptionModal';

export function UserDetailsPage() {
    const { id } = useParams<{ id: string }>();
    const [user, setUser] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [isModalOpen, setIsModalOpen] = useState(false);

    const fetchUser = async () => {
        try {
            const { data } = await api.get(`/admin/users/${id}`);
            setUser(data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchUser();
    }, [id]);

    const toggleStatus = async () => {
        if (!user) return;
        const newStatus = !user.isActive;
        const action = newStatus ? 'activate' : 'ban';

        if (confirm(`Are you sure you want to ${action} this user?`)) {
            try {
                await api.patch(`/admin/users/${user.id}/status`, { isActive: newStatus });
                fetchUser();
            } catch (error) {
                alert(`Failed to ${action} user`);
            }
        }
    };

    if (loading) return <div className="p-8 text-center text-gray-500">Loading user details...</div>;
    if (!user) return <div className="p-8 text-center text-red-500">User not found.</div>;

    return (
        <div>
            {/* Header */}
            <div className="flex items-center mb-8">
                <Link to="/users" className="mr-4 p-2 rounded-full hover:bg-gray-100 text-gray-600 transition-colors">
                    <ArrowLeft className="w-5 h-5" />
                </Link>
                <div>
                    <h1 className="text-2xl font-bold text-gray-800">{user.name || 'Unnamed User'}</h1>
                    <p className="text-gray-500">{user.email}</p>
                </div>
                <div className="ml-auto flex space-x-3 items-center">
                    <Badge variant={user.role === 'ADMIN' ? 'info' : 'default'}>{user.role}</Badge>

                    <button
                        onClick={toggleStatus}
                        className={`group flex items-center px-3 py-1 rounded-full text-xs font-semibold transition-all border ${user.isActive
                            ? 'bg-green-100 text-green-700 border-green-200 hover:bg-red-100 hover:text-red-700 hover:border-red-200'
                            : 'bg-red-100 text-red-700 border-red-200 hover:bg-green-100 hover:text-green-700 hover:border-green-200'
                            }`}
                    >
                        {user.isActive ? (
                            <>
                                <span className="group-hover:hidden">Active</span>
                                <span className="hidden group-hover:inline flex items-center">
                                    <Ban className="w-3 h-3 mr-1" /> Ban User
                                </span>
                            </>
                        ) : (
                            <>
                                <span className="group-hover:hidden">Banned</span>
                                <span className="hidden group-hover:inline flex items-center">
                                    <Plus className="w-3 h-3 mr-1" /> Activate
                                </span>
                            </>
                        )}
                    </button>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column: Stats & Subscriptions */}
                <div className="space-y-6 lg:col-span-2">
                    {/* Subscription Card */}
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                        <div className="flex justify-between items-center mb-4">
                            <h3 className="text-lg font-semibold text-gray-800 flex items-center">
                                <Activity className="w-5 h-5 mr-2 text-indigo-600" />
                                Current Subscription
                            </h3>
                            <button
                                onClick={() => setIsModalOpen(true)}
                                className="text-sm bg-indigo-50 text-indigo-600 hover:bg-indigo-100 px-3 py-1 rounded-lg font-medium transition-colors flex items-center"
                            >
                                <Plus className="w-4 h-4 mr-1" />
                                Assign Plan
                            </button>
                        </div>
                        {user.subscription && user.subscription.status === 'ACTIVE' ? (
                            <div className="bg-gradient-to-r from-indigo-50 to-blue-50 rounded-lg p-5 border border-indigo-100">
                                <div className="flex justify-between items-start">
                                    <div>
                                        <h4 className="font-bold text-indigo-900 text-lg">{user.subscription.plan.name}</h4>
                                        <p className="text-sm text-indigo-600">Expires: {new Date(user.subscription.expiresAt).toLocaleDateString()}</p>
                                    </div>
                                    <div className="flex flex-col items-end gap-2">
                                        <Badge variant="success">ACTIVE</Badge>
                                        <button
                                            onClick={async () => {
                                                if (confirm('Are you sure you want to cancel this subscription?')) {
                                                    try {
                                                        await api.patch(`/admin/subscriptions/${user.subscription.id}/cancel`);
                                                        fetchUser();
                                                    } catch (e) {
                                                        alert('Failed to cancel subscription');
                                                    }
                                                }
                                            }}
                                            className="text-xs text-red-600 hover:text-red-800 font-medium underline"
                                        >
                                            Cancel Plan
                                        </button>
                                    </div>
                                </div>
                            </div>
                        ) : (
                            <div className="text-center py-6 bg-gray-50 rounded-lg border border-dashed border-gray-200 flex flex-col items-center justify-center gap-2">
                                <p className="text-gray-500">No active subscription</p>
                                <button
                                    onClick={toggleStatus}
                                    className={`text-xs font-medium underline ${user.isActive ? 'text-red-500 hover:text-red-700' : 'text-green-600 hover:text-green-800'}`}
                                >
                                    {user.isActive ? 'Ban User' : 'Activate User'}
                                </button>
                            </div>
                        )}
                    </div>

                    {/* Routers List */}
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                        <div className="flex justify-between items-center mb-4">
                            <h3 className="text-lg font-semibold text-gray-800 flex items-center">
                                <Smartphone className="w-5 h-5 mr-2 text-indigo-600" />
                                Connected Routers
                            </h3>
                            <span className="text-sm bg-gray-100 px-2 py-1 rounded text-gray-600">
                                {user.routers.length} Total
                            </span>
                        </div>

                        {user.routers.length > 0 ? (
                            <div className="space-y-3">
                                {user.routers.map((router: any) => (
                                    <div key={router.id} className="flex justify-between items-center p-3 hover:bg-gray-50 rounded-lg border border-gray-100 transition-colors group">
                                        <div className="flex items-center">
                                            <div className={`w-2 h-2 rounded-full mr-3 ${router.status === 'ONLINE' ? 'bg-green-500' : 'bg-gray-300'}`}></div>
                                            <div>
                                                <div className="flex items-center gap-2">
                                                    <p className="font-medium text-gray-900">{router.name}</p>
                                                    <span className={`text-[10px] px-1.5 py-0.5 rounded uppercase font-bold tracking-wider ${router.status === 'ONLINE' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-500'
                                                        }`}>
                                                        {router.status === 'ONLINE' ? 'ONLINE' : 'OFFLINE'}
                                                    </span>
                                                    {router.radiusConnected ? (
                                                        <span className="text-[10px] px-1.5 py-0.5 rounded uppercase font-bold tracking-wider bg-blue-100 text-blue-700 flex items-center gap-0.5">
                                                            <Wifi className="w-3 h-3" />
                                                            RADIUS
                                                        </span>
                                                    ) : (
                                                        <span className="text-[10px] px-1.5 py-0.5 rounded uppercase font-bold tracking-wider bg-amber-100 text-amber-700 flex items-center gap-0.5">
                                                            <WifiOff className="w-3 h-3" />
                                                            No RADIUS
                                                        </span>
                                                    )}
                                                </div>
                                                <p className="text-xs text-gray-500 font-mono">{router.ipAddress}</p>
                                            </div>
                                        </div>
                                        <div className="flex items-center">
                                            <span className="text-xs text-gray-400 mr-3">
                                                Last seen: {new Date(router.lastSeen || router.updatedAt).toLocaleDateString()}
                                            </span>
                                            <button
                                                onClick={async () => {
                                                    if (confirm('Are you sure you want to delete this router?')) {
                                                        try {
                                                            await api.delete(`/admin/users/${user.id}/routers/${router.id}`);
                                                            fetchUser();
                                                        } catch (e) {
                                                            alert('Failed to delete router');
                                                        }
                                                    }
                                                }}
                                                className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition-colors opacity-0 group-hover:opacity-100"
                                                title="Delete Router"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                        </div>
                                    </div>
                                ))}
                            </div>
                        ) : (
                            <p className="text-sm text-gray-500">No routers added yet.</p>
                        )}
                    </div>
                </div>

                {/* Right Column: Payments & Info */}
                <div className="space-y-6">
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                        <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-4">Account Details</h3>
                        <div className="space-y-4">
                            <div>
                                <label className="text-xs text-gray-400">Network Name</label>
                                <p className="text-gray-900 font-medium">{user.networkName || 'N/A'}</p>
                            </div>
                            <div>
                                <label className="text-xs text-gray-400">Joined Date</label>
                                <p className="text-gray-900 font-medium flex items-center">
                                    <Calendar className="w-3 h-3 mr-1 text-gray-400" />
                                    {new Date(user.createdAt).toLocaleDateString()}
                                </p>
                            </div>
                            <div>
                                <label className="text-xs text-gray-400">User ID</label>
                                <p className="text-xs text-gray-500 font-mono bg-gray-50 p-1 rounded mt-1 break-all select-all">
                                    {user.id}
                                </p>
                            </div>
                        </div>
                    </div>

                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                        <div className="flex justify-between items-center mb-4">
                            <h3 className="text-lg font-semibold text-gray-800 flex items-center">
                                <CreditCard className="w-5 h-5 mr-2 text-indigo-600" />
                                Recent Payments
                            </h3>
                        </div>
                        <div className="space-y-4">
                            {user.payments && user.payments.length > 0 ? (
                                user.payments.slice(0, 5).map((pay: any) => (
                                    <div key={pay.id} className="flex justify-between items-center text-sm">
                                        <div>
                                            <p className="font-medium text-gray-900">${pay.amount}</p>
                                            <p className="text-xs text-gray-500">{new Date(pay.createdAt).toLocaleDateString()}</p>
                                        </div>
                                        <Badge variant={pay.status === 'APPROVED' ? 'success' : pay.status === 'PENDING' ? 'warning' : 'error'}>
                                            {pay.status}
                                        </Badge>
                                    </div>
                                ))
                            ) : (
                                <p className="text-sm text-gray-500">No payment history.</p>
                            )}
                            {user.payments && user.payments.length > 5 && (
                                <button className="text-xs text-indigo-600 hover:text-indigo-800 font-medium w-full text-center mt-2">
                                    View All History
                                </button>
                            )}
                        </div>
                    </div>
                </div>
            </div>

            <ManualSubscriptionModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                userId={user.id}
                onSuccess={fetchUser}
            />
        </div>
    );
}
