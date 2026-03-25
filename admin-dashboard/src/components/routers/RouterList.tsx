import { useState, useEffect, useCallback } from 'react';
import { Router as RouterIcon, Trash2, Edit, RefreshCw, Search } from 'lucide-react';
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

interface PaginationMeta {
    total: number;
    page: number;
    lastPage: number;
}

export function RouterList({ onEdit }: { onEdit: (router: Router) => void }) {
    const [routers, setRouters] = useState<Router[]>([]);
    const [loading, setLoading] = useState(true);
    const [checkingStatus, setCheckingStatus] = useState<Record<string, boolean>>({});
    const [page, setPage] = useState(1);
    const [meta, setMeta] = useState<PaginationMeta>({ total: 0, page: 1, lastPage: 1 });
    const [search, setSearch] = useState('');
    const limit = 20;

    const fetchRouters = useCallback(async () => {
        try {
            setLoading(true);
            const params: Record<string, string | number> = { page, limit };
            if (search) params.search = search;
            const response = await api.get('/admin/routers', { params });
            const data = response.data.data as Router[];
            setRouters(data);
            setMeta(response.data.meta);
            return data;
        } catch (error) {
            console.error('Failed to fetch routers:', error);
            return [];
        } finally {
            setLoading(false);
        }
    }, [page, search]);

    const refreshLiveStatuses = useCallback(async (routerList: Router[]) => {
        const checking: Record<string, boolean> = {};
        routerList.forEach(r => { checking[r.id] = true; });
        setCheckingStatus(checking);

        routerList.forEach(async (router) => {
            try {
                const res = await api.get(`/admin/routers/${router.id}/status`);
                const { status, lastSeen } = res.data;
                setRouters(prev =>
                    prev.map(r =>
                        r.id === router.id ? { ...r, status, lastSeen } : r
                    )
                );
            } catch {
                // Keep cached status on error
            } finally {
                setCheckingStatus(prev => ({ ...prev, [router.id]: false }));
            }
        });
    }, []);

    useEffect(() => {
        (async () => {
            const list = await fetchRouters();
            if (list.length > 0) {
                refreshLiveStatuses(list);
            }
        })();
    }, [fetchRouters, refreshLiveStatuses]);

    useEffect(() => {
        setPage(1);
    }, [search]);

    const handleRefresh = async () => {
        const list = await fetchRouters();
        if (list.length > 0) {
            refreshLiveStatuses(list);
        }
    };

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

    return (
        <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="p-4 border-b border-gray-200 flex justify-between items-center bg-gray-50">
                <h3 className="text-lg font-medium text-gray-900 flex items-center gap-2">
                    <RouterIcon className="h-5 w-5 text-indigo-600" />
                    Connected Routers
                </h3>
                <div className="flex items-center gap-2">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Search name, IP..."
                            className="pl-9 pr-3 py-1.5 border border-gray-300 rounded-md text-sm shadow-sm focus:border-indigo-500 focus:ring-indigo-500 w-52"
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                        />
                    </div>
                    <button
                        onClick={handleRefresh}
                        className="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100"
                        title="Refresh List & Check Status"
                    >
                        <RefreshCw className="h-4 w-4" />
                    </button>
                </div>
            </div>

            {loading ? (
                <div className="text-center py-8">Loading routers...</div>
            ) : routers.length === 0 ? (
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
                                    <span className={`px-2 inline-flex items-center gap-1 text-xs leading-5 font-semibold rounded-full ${router.status === 'ONLINE' ? 'bg-green-100 text-green-800' :
                                        router.status === 'ERROR' ? 'bg-red-100 text-red-800' :
                                            'bg-gray-100 text-gray-800'
                                        }`}>
                                        {checkingStatus[router.id] && (
                                            <span className="inline-block h-2 w-2 rounded-full bg-current animate-pulse" />
                                        )}
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

            {!loading && meta.lastPage > 1 && (
                <div className="px-6 py-3 border-t border-gray-200 bg-gray-50 flex justify-between items-center">
                    <span className="text-sm text-gray-700">
                        Page {meta.page} of {meta.lastPage} ({meta.total} total)
                    </span>
                    <div className="flex gap-2">
                        <button
                            disabled={page <= 1}
                            onClick={() => setPage(p => p - 1)}
                            className="px-3 py-1 text-sm border border-gray-300 rounded-md disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100"
                        >
                            Previous
                        </button>
                        <button
                            disabled={page >= meta.lastPage}
                            onClick={() => setPage(p => p + 1)}
                            className="px-3 py-1 text-sm border border-gray-300 rounded-md disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100"
                        >
                            Next
                        </button>
                    </div>
                </div>
            )}
        </div>
    );
}
