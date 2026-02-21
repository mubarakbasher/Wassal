import { useState, useEffect } from 'react';
import { RefreshCw, Printer, Trash2, Search } from 'lucide-react';
import api from '../../lib/axios';

interface Voucher {
    id: string;
    username: string;
    password?: string;
    planName: string;
    planType?: string;
    countType?: 'WALL_CLOCK' | 'ONLINE_ONLY';
    duration?: number;
    price: string;
    status: 'UNUSED' | 'ACTIVE' | 'EXPIRED' | 'SOLD';
    createdAt: string;
    router?: {
        name: string;
        user?: {
            name: string;
            email: string;
        };
    };
}

export function VoucherList() {
    const [vouchers, setVouchers] = useState<Voucher[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('ALL');
    const [search, setSearch] = useState('');

    const fetchVouchers = async () => {
        try {
            setLoading(true);
            const response = await api.get('/admin/vouchers');
            setVouchers(response.data);
        } catch (error) {
            console.error('Failed to fetch vouchers:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchVouchers();
    }, []);

    const displayedVouchers = vouchers.filter(v => {
        // Status filter
        if (filter !== 'ALL' && v.status !== filter) return false;
        // Search filter
        if (search) {
            const q = search.toLowerCase();
            return (
                v.username.toLowerCase().includes(q) ||
                (v.planName || '').toLowerCase().includes(q) ||
                (v.router?.name || '').toLowerCase().includes(q) ||
                (v.router?.user?.name || '').toLowerCase().includes(q) ||
                (v.router?.user?.email || '').toLowerCase().includes(q)
            );
        }
        return true;
    });

    const getStatusColor = (status: string) => {
        switch (status) {
            case 'UNUSED': return 'bg-gray-100 text-gray-800';
            case 'ACTIVE': return 'bg-green-100 text-green-800';
            case 'EXPIRED': return 'bg-red-100 text-red-800';
            case 'SOLD': return 'bg-blue-100 text-blue-800';
            default: return 'bg-gray-100 text-gray-800';
        }
    };

    const handleDelete = async (id: string) => {
        if (!confirm('Are you sure you want to delete this voucher?')) return;
        try {
            await api.delete(`/admin/vouchers/${id}`);
            fetchVouchers();
        } catch (error) {
            console.error('Failed to delete voucher:', error);
            alert('Failed to delete voucher');
        }
    };

    const handlePrint = (voucher: Voucher) => {
        const printWindow = window.open('', '_blank');
        if (printWindow) {
            printWindow.document.write(`
        <html>
          <head>
            <title>Voucher ${voucher.username}</title>
            <style>
              body { font-family: 'Segoe UI', sans-serif; padding: 24px; text-align: center; border: 2px dashed #4f46e5; border-radius: 12px; width: 300px; margin: 0 auto; }
              h2 { margin: 0; color: #4f46e5; font-size: 16px; }
              .label { font-size: 11px; color: #888; text-transform: uppercase; letter-spacing: 1px; margin-top: 12px; }
              .code { font-size: 28px; font-weight: bold; margin: 6px 0 12px; letter-spacing: 3px; color: #111; font-family: monospace; }
              .details { font-size: 13px; color: #555; }
              .hint { font-size: 11px; color: #999; margin-top: 12px; }
            </style>
          </head>
          <body>
            <h2>Wi-Fi Access Code</h2>
            <div class="label">Enter this code to connect</div>
            <div class="code">${voucher.username}</div>
            <div class="details">
              ${voucher.planName} · ${Number(voucher.price) > 0 ? '$' + voucher.price : 'Free'}
            </div>
            <div class="hint">Username only — no password needed</div>
            <script>window.print();</script>
          </body>
        </html>
      `);
            printWindow.document.close();
        }
    };

    return (
        <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="p-4 border-b border-gray-200 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-3 bg-gray-50">
                <div className="flex items-center gap-4">
                    <h3 className="text-lg font-medium text-gray-900">Vouchers</h3>
                    <select
                        className="border-gray-300 rounded-md text-sm shadow-sm focus:border-indigo-500 focus:ring-indigo-500"
                        value={filter}
                        onChange={(e) => setFilter(e.target.value)}
                    >
                        <option value="ALL">All Status</option>
                        <option value="UNUSED">Unused</option>
                        <option value="ACTIVE">Active</option>
                        <option value="SOLD">Sold</option>
                        <option value="EXPIRED">Expired</option>
                    </select>
                </div>
                <div className="flex items-center gap-2">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Search code, owner, router..."
                            className="pl-9 pr-3 py-1.5 border border-gray-300 rounded-md text-sm shadow-sm focus:border-indigo-500 focus:ring-indigo-500 w-64"
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                        />
                    </div>
                    <button
                        onClick={fetchVouchers}
                        className="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100"
                        title="Refresh List"
                    >
                        <RefreshCw className="h-4 w-4" />
                    </button>
                </div>
            </div>

            {loading ? (
                <div className="text-center py-8">Loading vouchers...</div>
            ) : displayedVouchers.length === 0 ? (
                <div className="p-8 text-center text-gray-500">
                    No vouchers found.
                </div>
            ) : (
                <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                        <thead className="bg-gray-50">
                            <tr>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Access Code</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Plan</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Router</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Owner</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
                                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                            </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                            {displayedVouchers.map((voucher) => (
                                <tr key={voucher.id}>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="text-sm font-mono font-bold text-gray-900 tracking-wider">{voucher.username}</div>
                                        <div className="text-xs text-gray-400">Username only</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {voucher.planName}
                                        {voucher.planType === 'TIME_BASED' && voucher.duration && (
                                            <div className="text-xs text-gray-400">
                                                {voucher.duration}min · {voucher.countType === 'ONLINE_ONLY' ? 'Online Only' : 'Total Time'}
                                            </div>
                                        )}
                                        <div className="text-xs">{voucher.price}</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {voucher.router?.name || '-'}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <div className="text-sm text-gray-900">{voucher.router?.user?.name || 'N/A'}</div>
                                        <div className="text-xs text-gray-500">{voucher.router?.user?.email || ''}</div>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap">
                                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(voucher.status)}`}>
                                            {voucher.status}
                                        </span>
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                        {new Date(voucher.createdAt).toLocaleDateString()}
                                    </td>
                                    <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                        <button
                                            onClick={() => handlePrint(voucher)}
                                            className="text-gray-600 hover:text-gray-900 mr-4"
                                            title="Print"
                                        >
                                            <Printer className="h-4 w-4" />
                                        </button>
                                        <button
                                            onClick={() => handleDelete(voucher.id)}
                                            className="text-red-600 hover:text-red-900"
                                            title="Delete"
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}

