import { useState, useEffect } from 'react';
import { Router as RouterIcon, Trash2, Edit, RefreshCw } from 'lucide-react';
import api from '../../lib/axios';

interface Router {
    id: string;
    name: string;
    ipAddress: string;
    status: 'ONLINE' | 'OFFLINE' | 'ERROR';
    lastSeen?: string;
    user?: {
        name: string;
        email: string;
    };
    _count?: {
        vouchers: number;
        sessions: number;
    };
}

export function RouterList({ onEdit }: { onEdit: (router: Router) => void }) {
    const [routers, setRouters] = useState<Router[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchRouters = async () => {
        try {
            setLoading(true);
            const response = await api.get('/admin/routers');
            setRouters(response.data);
        } catch (error) {
            console.error('Failed to fetch routers:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchRouters();
    }, []);

    const handleDelete = async (id: string) => {
        if (!confirm('Are you sure you want to delete this router?')) return;
        try {
            await api.delete(`/admin/routers/${id}`);
            fetchRouters();
        } catch (error) {
            console.error('Failed to delete router:', error);
            alert('Failed to delete router');
        }
    };

    if (loading) {
        return <div className="text-center py-8">Loading routers...</div>;
    }

    return (
        <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="p-4 border-b border-gray-200 flex justify-between items-center bg-gray-50">
                <h3 className="text-lg font-medium text-gray-900 flex items-center gap-2">
                    <RouterIcon className="h-5 w-5 text-indigo-600" />
                    Connected Routers
                </h3>
                <button
                    onClick={fetchRouters}
                    className="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100"
                    title="Refresh List"
                >
                    <RefreshCw className="h-4 w-4" />
                </button>
            </div>

            {routers.length === 0 ? (
                <div className="p-8 text-center text-gray-500">
                    No routers found. Add one to get started.
                </div>
            ) : (
                <table className="min-w-full divide-y divide-gray-200">
                    <thead className="bg-gray-50">
                        <tr>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">IP Address</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Owner</th>
                            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Usage</th>
                            <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                        {routers.map((router) => (
                            <tr key={router.id}>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="text-sm font-medium text-gray-900">{router.name}</div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    {router.ipAddress}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${router.status === 'ONLINE' ? 'bg-green-100 text-green-800' :
                                        router.status === 'ERROR' ? 'bg-red-100 text-red-800' :
                                            'bg-gray-100 text-gray-800'
                                        }`}>
                                        {router.status}
                                    </span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <div className="text-sm text-gray-900">{router.user?.name || 'N/A'}</div>
                                    <div className="text-xs text-gray-500">{router.user?.email || ''}</div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                    <div className="flex flex-col">
                                        <span>{router._count?.vouchers || 0} Vouchers</span>
                                        <span>{router._count?.sessions || 0} Sessions</span>
                                    </div>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                    <button
                                        onClick={() => onEdit(router)}
                                        className="text-indigo-600 hover:text-indigo-900 mr-4"
                                    >
                                        <Edit className="h-4 w-4" />
                                    </button>
                                    <button
                                        onClick={() => handleDelete(router.id)}
                                        className="text-red-600 hover:text-red-900"
                                    >
                                        <Trash2 className="h-4 w-4" />
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            )}
        </div>
    );
}
