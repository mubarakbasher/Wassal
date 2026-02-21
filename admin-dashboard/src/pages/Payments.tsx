import { useState, useEffect } from 'react';
import { CheckCircle, XCircle, Eye, Download } from 'lucide-react';
import api from '../lib/axios';
import { Badge } from '../components/ui/Badge';

export function PaymentsPage() {
    const [payments, setPayments] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('ALL');

    useEffect(() => {
        fetchPayments();
    }, [filter]);

    const fetchPayments = async () => {
        setLoading(true);
        try {
            const { data } = await api.get('/admin/payments', {
                params: { status: filter }
            });
            setPayments(data.data);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    const handleReview = async (id: string, status: 'APPROVED' | 'REJECTED') => {
        if (!window.confirm(`Are you sure you want to ${status} this payment?`)) return;
        try {
            await api.patch(`/admin/payments/${id}/review`, { status });
            fetchPayments();
        } catch (e) {
            alert('Failed to update payment');
        }
    };

    const handleExport = async () => {
        try {
            const response = await api.get('/admin/payments/export', { responseType: 'blob' });
            const url = window.URL.createObjectURL(new Blob([response.data]));
            const link = document.createElement('a');
            link.href = url;
            link.setAttribute('download', `payments_${new Date().toISOString().slice(0, 10)}.csv`);
            document.body.appendChild(link);
            link.click();
            link.remove();
        } catch (error) {
            alert('Failed to export payments');
        }
    };

    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Payment Monitoring</h1>
                <div className="flex items-center space-x-2">
                    <button
                        onClick={handleExport}
                        className="flex items-center px-3 py-2 text-sm border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors mr-2"
                    >
                        <Download className="w-4 h-4 mr-1" />
                        Export
                    </button>
                    {['ALL', 'PENDING', 'APPROVED', 'REJECTED'].map((status) => (
                        <button
                            key={status}
                            onClick={() => setFilter(status)}
                            className={`px-4 py-2 text-sm font-medium rounded-lg border ${filter === status
                                    ? 'bg-indigo-50 border-indigo-200 text-indigo-700'
                                    : 'bg-white border-gray-200 text-gray-600 hover:bg-gray-50'
                                }`}
                        >
                            {status.charAt(0) + status.slice(1).toLowerCase()}
                        </button>
                    ))}
                </div>
            </div>

            <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                <table className="w-full text-left">
                    <thead className="bg-gray-50 border-b border-gray-100">
                        <tr>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">User</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Amount</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Method</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Status</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Date</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {loading ? (
                            <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-500">Loading...</td></tr>
                        ) : payments.length === 0 ? (
                            <tr><td colSpan={6} className="px-6 py-8 text-center text-gray-500">No payments found</td></tr>
                        ) : (
                            payments.map((payment) => (
                                <tr key={payment.id} className="hover:bg-gray-50 transition-colors">
                                    <td className="px-6 py-4">
                                        <div className="font-medium text-gray-900">{payment.user?.name || 'Unknown'}</div>
                                        <div className="text-sm text-gray-500">{payment.user?.email}</div>
                                    </td>
                                    <td className="px-6 py-4 font-bold text-gray-900">
                                        ${payment.amount}
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-600">
                                        {payment.method}
                                    </td>
                                    <td className="px-6 py-4">
                                        <Badge variant={
                                            payment.status === 'APPROVED' ? 'success' :
                                                payment.status === 'PENDING' ? 'warning' : 'error'
                                        }>
                                            {payment.status}
                                        </Badge>
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-500">
                                        {new Date(payment.createdAt).toLocaleDateString()}
                                    </td>
                                    <td className="px-6 py-4 text-right space-x-2">
                                        {payment.status === 'PENDING' && (
                                            <>
                                                <button
                                                    onClick={() => handleReview(payment.id, 'APPROVED')}
                                                    className="p-1 text-green-600 hover:bg-green-50 rounded"
                                                    title="Approve"
                                                >
                                                    <CheckCircle className="w-5 h-5" />
                                                </button>
                                                <button
                                                    onClick={() => handleReview(payment.id, 'REJECTED')}
                                                    className="p-1 text-red-600 hover:bg-red-50 rounded"
                                                    title="Reject"
                                                >
                                                    <XCircle className="w-5 h-5" />
                                                </button>
                                            </>
                                        )}
                                        {payment.proofUrl && (
                                            <a href={payment.proofUrl} target="_blank" rel="noreferrer" className="inline-block p-1 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded" title="View Proof">
                                                <Eye className="w-5 h-5" />
                                            </a>
                                        )}
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>
        </div>
    );
}
