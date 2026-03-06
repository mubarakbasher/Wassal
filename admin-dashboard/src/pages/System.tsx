import { useState, useEffect } from 'react';
import { Activity, Settings, FileText, Save, AlertTriangle, Landmark, CheckCircle } from 'lucide-react';
import api from '../lib/axios';

const Tabs = ({ active, onChange, items }: any) => (
    <div className="flex space-x-1 border-b border-gray-200 mb-6">
        {items.map((item: any) => (
            <button
                key={item.id}
                onClick={() => onChange(item.id)}
                className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${active === item.id
                        ? 'border-indigo-600 text-indigo-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700'
                    }`}
            >
                <div className="flex items-center">
                    <item.icon className="w-4 h-4 mr-2" />
                    {item.label}
                </div>
            </button>
        ))}
    </div>
);

export function SystemPage() {
    const [activeTab, setActiveTab] = useState('status');
    const [logs, setLogs] = useState<any[]>([]);
    const [_config, setConfig] = useState<any[]>([]);
    const [bank, setBank] = useState({ bank_name: '', bank_account_name: '', bank_account_number: '' });
    const [bankLoading, setBankLoading] = useState(false);
    const [bankMsg, setBankMsg] = useState('');

    useEffect(() => {
        if (activeTab === 'logs') fetchLogs();
        if (activeTab === 'config') {
            fetchConfig();
            fetchBankInfo();
        }
    }, [activeTab]);

    const fetchLogs = async () => {
        try {
            const { data } = await api.get('/admin/system/audit-logs');
            setLogs(data.data);
        } catch (e) {
            console.error(e);
        }
    };

    const fetchConfig = async () => {
        try {
            const { data } = await api.get('/admin/system/config');
            setConfig(data);
        } catch (e) {
            console.error(e);
        }
    };

    const fetchBankInfo = async () => {
        try {
            const { data } = await api.get('/admin/system/config');
            const configMap: Record<string, string> = {};
            for (const item of data) {
                configMap[item.key] = item.value;
            }
            setBank({
                bank_name: configMap['bank_name'] || '',
                bank_account_name: configMap['bank_account_name'] || '',
                bank_account_number: configMap['bank_account_number'] || '',
            });
        } catch (e) {
            console.error(e);
        }
    };

    const handleBankSave = async () => {
        setBankLoading(true);
        setBankMsg('');
        try {
            await Promise.all(
                Object.entries(bank).map(([key, value]) =>
                    api.post('/admin/system/config', { key, value })
                )
            );
            setBankMsg('Bank details saved successfully');
            setTimeout(() => setBankMsg(''), 3000);
        } catch (e) {
            setBankMsg('Failed to save bank details');
        } finally {
            setBankLoading(false);
        }
    };

    return (
        <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-6">System & Monitoring</h1>

            <Tabs
                active={activeTab}
                onChange={setActiveTab}
                items={[
                    { id: 'status', label: 'System Status', icon: Activity },
                    { id: 'config', label: 'Configuration', icon: Settings },
                    { id: 'logs', label: 'Audit Logs', icon: FileText },
                ]}
            />

            {activeTab === 'status' && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                        <div>
                            <h3 className="text-lg font-semibold text-gray-900">API Health</h3>
                            <p className="text-sm text-gray-500 mt-1">Status: <span className="text-green-600 font-bold">ONLINE</span></p>
                            <p className="text-xs text-gray-400 mt-1">Uptime: 99.98%</p>
                        </div>
                        <div className="p-3 bg-green-50 rounded-full">
                            <Activity className="w-6 h-6 text-green-600" />
                        </div>
                    </div>

                    <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 flex items-center justify-between">
                        <div>
                            <h3 className="text-lg font-semibold text-gray-900">Maintenance Mode</h3>
                            <p className="text-sm text-gray-500 mt-1">Current: <span className="text-gray-600 font-bold">OFF</span></p>
                        </div>
                        <div className="p-3 bg-gray-50 rounded-full">
                            <AlertTriangle className="w-6 h-6 text-gray-600" />
                        </div>
                    </div>
                </div>
            )}

            {activeTab === 'config' && (
                <div className="space-y-6">
                    {/* Bank Account Details */}
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                        <div className="flex items-center mb-6">
                            <div className="p-2 bg-indigo-50 rounded-lg mr-3">
                                <Landmark className="w-5 h-5 text-indigo-600" />
                            </div>
                            <div>
                                <h3 className="text-lg font-semibold text-gray-800">Bank Account Details</h3>
                                <p className="text-sm text-gray-500">Shown to users when they request a subscription payment</p>
                            </div>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Bank Name</label>
                                <input
                                    type="text"
                                    value={bank.bank_name}
                                    onChange={(e) => setBank({ ...bank, bank_name: e.target.value })}
                                    placeholder="e.g. Bankak"
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Account Name</label>
                                <input
                                    type="text"
                                    value={bank.bank_account_name}
                                    onChange={(e) => setBank({ ...bank, bank_account_name: e.target.value })}
                                    placeholder="e.g. Wassal Company"
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                                />
                            </div>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Account Number</label>
                                <input
                                    type="text"
                                    value={bank.bank_account_number}
                                    onChange={(e) => setBank({ ...bank, bank_account_number: e.target.value })}
                                    placeholder="e.g. 1234567890"
                                    className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                                />
                            </div>
                        </div>

                        {bankMsg && (
                            <div className={`flex items-center text-sm mt-4 p-3 rounded-lg ${bankMsg.includes('Failed') ? 'text-red-600 bg-red-50' : 'text-green-600 bg-green-50'}`}>
                                <CheckCircle className="w-4 h-4 mr-2" />
                                {bankMsg}
                            </div>
                        )}

                        <div className="mt-4 flex justify-end">
                            <button
                                onClick={handleBankSave}
                                disabled={bankLoading}
                                className="flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition-colors"
                            >
                                <Save className="w-4 h-4 mr-2" />
                                {bankLoading ? 'Saving...' : 'Save Bank Details'}
                            </button>
                        </div>
                    </div>

                    {/* Feature Flags */}
                    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                        <h3 className="text-lg font-semibold text-gray-800 mb-4">Global Feature Flags</h3>
                        <div className="space-y-4">
                            <div className="flex items-center justify-between p-4 border rounded-lg">
                                <div>
                                    <p className="font-medium text-gray-900">Allow User Registration</p>
                                    <p className="text-sm text-gray-500">Enable or disable new user signups globally</p>
                                </div>
                                <input type="checkbox" defaultChecked className="toggle" />
                            </div>
                            <div className="flex items-center justify-between p-4 border rounded-lg">
                                <div>
                                    <p className="font-medium text-gray-900">Emergency Read-Only Mode</p>
                                    <p className="text-sm text-gray-500">Disable all write operations during maintenance</p>
                                </div>
                                <input type="checkbox" className="toggle" />
                            </div>
                        </div>
                        <div className="mt-6 flex justify-end">
                            <button className="flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700">
                                <Save className="w-4 h-4 mr-2" />
                                Save Changes
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {activeTab === 'logs' && (
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                    <table className="w-full text-left">
                        <thead className="bg-gray-50 border-b border-gray-100">
                            <tr>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Timestamp</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Admin</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Action</th>
                                <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Details</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {logs.length === 0 ? (
                                <tr>
                                    <td colSpan={4} className="px-6 py-8 text-center text-gray-500">No logs found</td>
                                </tr>
                            ) : (
                                logs.map((log) => (
                                    <tr key={log.id}>
                                        <td className="px-6 py-4 text-sm text-gray-500">
                                            {new Date(log.createdAt).toLocaleString()}
                                        </td>
                                        <td className="px-6 py-4 text-sm font-medium text-gray-900">
                                            {log.admin?.email}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-indigo-600 font-medium">
                                            {log.action}
                                        </td>
                                        <td className="px-6 py-4 text-sm text-gray-600 font-mono">
                                            {JSON.stringify(log.details)}
                                        </td>
                                    </tr>
                                ))
                            )}
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
}
