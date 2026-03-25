import { useState, useEffect, useMemo } from 'react';
import { X, Search, Loader2, Router as RouterIcon, ArrowRight } from 'lucide-react';
import api from '../../lib/axios';

interface AssignRouterModalProps {
    userId: string;
    userRouterIds: string[];
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
}

interface RouterItem {
    id: string;
    name: string;
    ipAddress: string;
    status: string;
    userId: string;
    user?: { name: string; email: string };
}

export function AssignRouterModal({ userId, userRouterIds, isOpen, onClose, onSuccess }: AssignRouterModalProps) {
    const [routers, setRouters] = useState<RouterItem[]>([]);
    const [loading, setLoading] = useState(true);
    const [assigning, setAssigning] = useState<string | null>(null);
    const [error, setError] = useState('');
    const [search, setSearch] = useState('');

    useEffect(() => {
        if (!isOpen) return;
        setLoading(true);
        setError('');
        setSearch('');
        api.get('/admin/routers')
            .then(({ data }) => setRouters(data))
            .catch(() => setError('Failed to load routers'))
            .finally(() => setLoading(false));
    }, [isOpen]);

    const availableRouters = useMemo(() => {
        const filtered = routers.filter(r => !userRouterIds.includes(r.id));
        if (!search.trim()) return filtered;
        const q = search.toLowerCase();
        return filtered.filter(r =>
            r.name.toLowerCase().includes(q) ||
            r.ipAddress.includes(q) ||
            r.user?.name?.toLowerCase().includes(q) ||
            r.user?.email?.toLowerCase().includes(q)
        );
    }, [routers, userRouterIds, search]);

    const handleAssign = async (routerId: string) => {
        setAssigning(routerId);
        setError('');
        try {
            await api.post(`/admin/users/${userId}/routers/${routerId}`);
            onSuccess();
            onClose();
        } catch (err: any) {
            setError(err.response?.data?.message || 'Failed to assign router');
        } finally {
            setAssigning(null);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-lg overflow-hidden max-h-[80vh] flex flex-col">
                <div className="flex justify-between items-center p-4 border-b border-gray-200">
                    <h3 className="text-lg font-medium text-gray-900">Assign Existing Router</h3>
                    <button onClick={onClose} className="text-gray-400 hover:text-gray-500">
                        <X className="h-5 w-5" />
                    </button>
                </div>

                <div className="p-4 border-b border-gray-100">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Search by name, IP, or owner..."
                            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-md text-sm focus:border-indigo-500 focus:ring-indigo-500"
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                        />
                    </div>
                </div>

                {error && (
                    <div className="mx-4 mt-3 bg-red-50 text-red-700 p-3 rounded-md text-sm">
                        {error}
                    </div>
                )}

                <div className="flex-1 overflow-y-auto p-4">
                    {loading ? (
                        <div className="flex items-center justify-center py-12 text-gray-400">
                            <Loader2 className="animate-spin h-6 w-6 mr-2" />
                            Loading routers...
                        </div>
                    ) : availableRouters.length === 0 ? (
                        <div className="text-center py-12 text-gray-500">
                            <RouterIcon className="h-10 w-10 mx-auto mb-3 text-gray-300" />
                            <p className="font-medium">No available routers</p>
                            <p className="text-sm text-gray-400 mt-1">
                                {search ? 'No routers match your search.' : 'All routers are already assigned to this user.'}
                            </p>
                        </div>
                    ) : (
                        <div className="space-y-2">
                            {availableRouters.map((router) => (
                                <div
                                    key={router.id}
                                    className="flex items-center justify-between p-3 rounded-lg border border-gray-100 hover:border-indigo-200 hover:bg-indigo-50/50 transition-colors group"
                                >
                                    <div className="flex items-center min-w-0">
                                        <div className={`w-2 h-2 rounded-full mr-3 flex-shrink-0 ${router.status === 'ONLINE' ? 'bg-green-500' : 'bg-gray-300'}`} />
                                        <div className="min-w-0">
                                            <p className="font-medium text-gray-900 truncate">{router.name}</p>
                                            <p className="text-xs text-gray-500 font-mono">{router.ipAddress}</p>
                                            {router.user && (
                                                <p className="text-xs text-gray-400 truncate">
                                                    Owner: {router.user.name || router.user.email}
                                                </p>
                                            )}
                                        </div>
                                    </div>
                                    <button
                                        onClick={() => handleAssign(router.id)}
                                        disabled={assigning !== null}
                                        className="flex-shrink-0 ml-3 flex items-center px-3 py-1.5 text-xs font-medium text-indigo-600 bg-indigo-50 hover:bg-indigo-100 rounded-md transition-colors disabled:opacity-50"
                                    >
                                        {assigning === router.id ? (
                                            <Loader2 className="animate-spin h-3.5 w-3.5" />
                                        ) : (
                                            <>
                                                Assign <ArrowRight className="h-3.5 w-3.5 ml-1" />
                                            </>
                                        )}
                                    </button>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                <div className="p-4 border-t border-gray-100 bg-gray-50">
                    <button
                        onClick={onClose}
                        className="w-full px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                    >
                        Cancel
                    </button>
                </div>
            </div>
        </div>
    );
}
