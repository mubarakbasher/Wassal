import { useState, useEffect, useMemo } from 'react';
import { X, Save, Loader2, Copy, CheckCircle, Terminal, Settings, Search, ClipboardCopy } from 'lucide-react';
import api from '../../lib/axios';

interface Router {
    id?: string;
    name: string;
    ipAddress: string;
    username: string;
    password?: string;
    apiPort: number;
    description?: string;
}

interface RouterFormProps {
    initialData?: Router | null;
    userId?: string;
    onClose: () => void;
    onSave: () => void;
}

interface UserOption {
    id: string;
    name: string | null;
    email: string;
}

interface ScriptStep {
    title: string;
    command: string;
    description: string;
}

export function RouterForm({ initialData, userId: fixedUserId, onClose, onSave }: RouterFormProps) {
    const isEditing = !!initialData?.id;
    const [activeTab, setActiveTab] = useState<'manual' | 'script'>(isEditing ? 'manual' : 'manual');

    // User selector state
    const [users, setUsers] = useState<UserOption[]>([]);
    const [usersLoading, setUsersLoading] = useState(false);
    const [selectedUserId, setSelectedUserId] = useState(fixedUserId || '');
    const [userSearch, setUserSearch] = useState('');

    // Manual form state
    const [formData, setFormData] = useState<Router>({
        name: '',
        ipAddress: '',
        username: '',
        password: '',
        apiPort: 8728,
        description: '',
    });
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');

    // Script tab state
    const [scriptLoading, setScriptLoading] = useState(false);
    const [scriptError, setScriptError] = useState('');
    const [vpnIp, setVpnIp] = useState('');
    const [steps, setSteps] = useState<ScriptStep[]>([]);
    const [copiedIdx, setCopiedIdx] = useState<number | null>(null);

    useEffect(() => {
        if (initialData) {
            setFormData({ ...initialData, password: '' });
        }
    }, [initialData]);

    useEffect(() => {
        if (isEditing) return;
        setUsersLoading(true);
        api.get('/admin/users?limit=200')
            .then(({ data }) => setUsers(data.data || []))
            .catch(() => {})
            .finally(() => setUsersLoading(false));
    }, [isEditing]);

    const filteredUsers = useMemo(() => {
        if (!userSearch.trim()) return users;
        const q = userSearch.toLowerCase();
        return users.filter(u =>
            (u.name || '').toLowerCase().includes(q) ||
            u.email.toLowerCase().includes(q)
        );
    }, [users, userSearch]);

    const handleManualSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!isEditing && !selectedUserId) {
            setError('Please select a user to assign this router to.');
            return;
        }
        setLoading(true);
        setError('');

        try {
            if (isEditing) {
                const dataToSend = { ...formData };
                if (!dataToSend.password) delete dataToSend.password;
                await api.patch(`/admin/routers/${initialData!.id}`, dataToSend);
            } else {
                await api.post('/admin/routers', { ...formData, userId: selectedUserId });
            }
            onSave();
            onClose();
        } catch (err: any) {
            setError(err.response?.data?.message || 'Failed to save router');
        } finally {
            setLoading(false);
        }
    };

    const handleGenerateScript = async () => {
        if (!selectedUserId) {
            setScriptError('Please select a user first.');
            return;
        }
        setScriptLoading(true);
        setScriptError('');
        setSteps([]);
        setVpnIp('');

        try {
            const { data } = await api.post('/admin/routers/wireguard-setup', { userId: selectedUserId });
            setVpnIp(data.vpnIp);
            setSteps(data.steps);
        } catch (err: any) {
            setScriptError(err.response?.data?.message || 'Failed to generate WireGuard setup.');
        } finally {
            setScriptLoading(false);
        }
    };

    const copyToClipboard = (text: string, idx: number) => {
        navigator.clipboard.writeText(text);
        setCopiedIdx(idx);
        setTimeout(() => setCopiedIdx(null), 2000);
    };

    const copyAllCommands = () => {
        const all = steps.map(s => s.command).join('\n');
        navigator.clipboard.writeText(all);
        setCopiedIdx(-1);
        setTimeout(() => setCopiedIdx(null), 2000);
    };

    const inputClass = 'mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 border p-2 text-sm';

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-lg overflow-hidden max-h-[90vh] flex flex-col">
                {/* Header */}
                <div className="flex justify-between items-center p-4 border-b border-gray-200">
                    <h3 className="text-lg font-medium text-gray-900">
                        {isEditing ? 'Edit Router' : 'Add New Router'}
                    </h3>
                    <button onClick={onClose} className="text-gray-400 hover:text-gray-500">
                        <X className="h-5 w-5" />
                    </button>
                </div>

                {/* Tabs (only when creating) */}
                {!isEditing && (
                    <div className="flex border-b border-gray-200">
                        <button
                            onClick={() => setActiveTab('manual')}
                            className={`flex-1 flex items-center justify-center gap-2 py-3 text-sm font-medium transition-colors ${activeTab === 'manual'
                                ? 'text-indigo-600 border-b-2 border-indigo-600'
                                : 'text-gray-500 hover:text-gray-700'
                                }`}
                        >
                            <Settings className="h-4 w-4" />
                            Manual
                        </button>
                        <button
                            onClick={() => setActiveTab('script')}
                            className={`flex-1 flex items-center justify-center gap-2 py-3 text-sm font-medium transition-colors ${activeTab === 'script'
                                ? 'text-indigo-600 border-b-2 border-indigo-600'
                                : 'text-gray-500 hover:text-gray-700'
                                }`}
                        >
                            <Terminal className="h-4 w-4" />
                            By Script
                        </button>
                    </div>
                )}

                <div className="flex-1 overflow-y-auto">
                    {/* User Selector (shown when creating, in both tabs) */}
                    {!isEditing && (
                        <div className="p-4 pb-0">
                            <label className="block text-sm font-medium text-gray-700 mb-1">Assign to User *</label>
                            {fixedUserId ? (
                                <div className="bg-gray-50 border border-gray-200 rounded-md p-2 text-sm text-gray-700">
                                    {users.find(u => u.id === fixedUserId)?.name || fixedUserId}
                                    <span className="text-gray-400 ml-1">
                                        ({users.find(u => u.id === fixedUserId)?.email || 'loading...'})
                                    </span>
                                </div>
                            ) : (
                                <div className="space-y-1.5">
                                    <div className="relative">
                                        <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                                        <input
                                            type="text"
                                            placeholder="Search users..."
                                            className="w-full pl-8 pr-3 py-1.5 border border-gray-300 rounded-md text-sm focus:border-indigo-500 focus:ring-indigo-500"
                                            value={userSearch}
                                            onChange={(e) => setUserSearch(e.target.value)}
                                        />
                                    </div>
                                    {usersLoading ? (
                                        <div className="text-xs text-gray-400 py-2 text-center">Loading users...</div>
                                    ) : (
                                        <select
                                            required
                                            value={selectedUserId}
                                            onChange={(e) => setSelectedUserId(e.target.value)}
                                            className={inputClass}
                                            size={Math.min(filteredUsers.length + 1, 5)}
                                        >
                                            <option value="">-- Select a user --</option>
                                            {filteredUsers.map(u => (
                                                <option key={u.id} value={u.id}>
                                                    {u.name || 'Unnamed'} — {u.email}
                                                </option>
                                            ))}
                                        </select>
                                    )}
                                </div>
                            )}
                        </div>
                    )}

                    {/* Manual Tab */}
                    {activeTab === 'manual' && (
                        <form onSubmit={handleManualSubmit} className="p-4 space-y-4" id="manual-form">
                            {error && (
                                <div className="bg-red-50 text-red-700 p-3 rounded-md text-sm">{error}</div>
                            )}

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Name</label>
                                <input
                                    type="text" required className={inputClass}
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    placeholder="e.g. Main Office Router"
                                />
                            </div>

                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">IP Address</label>
                                    <input
                                        type="text" required className={inputClass}
                                        value={formData.ipAddress}
                                        onChange={(e) => setFormData({ ...formData, ipAddress: e.target.value })}
                                        placeholder="192.168.88.1"
                                    />
                                </div>
                                <div>
                                    <label className="block text-sm font-medium text-gray-700">API Port</label>
                                    <input
                                        type="number" required className={inputClass}
                                        value={formData.apiPort}
                                        onChange={(e) => setFormData({ ...formData, apiPort: parseInt(e.target.value) })}
                                    />
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Username</label>
                                <input
                                    type="text" required className={inputClass}
                                    value={formData.username}
                                    onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                                    placeholder="admin"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">
                                    Password {isEditing && <span className="text-gray-400 font-normal">(Leave empty to keep current)</span>}
                                </label>
                                <input
                                    type="password" className={inputClass}
                                    value={formData.password}
                                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                                    required={!isEditing}
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700">Description (Optional)</label>
                                <textarea
                                    className={inputClass} rows={2}
                                    value={formData.description}
                                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                />
                            </div>
                        </form>
                    )}

                    {/* Script Tab */}
                    {activeTab === 'script' && (
                        <div className="p-4 space-y-4">
                            {scriptError && (
                                <div className="bg-red-50 text-red-700 p-3 rounded-md text-sm">{scriptError}</div>
                            )}

                            {steps.length === 0 ? (
                                <div className="text-center py-8">
                                    <Terminal className="h-12 w-12 mx-auto mb-4 text-indigo-300" />
                                    <p className="text-sm text-gray-600 mb-1">
                                        Generate WireGuard VPN setup commands for the selected user.
                                    </p>
                                    <p className="text-xs text-gray-400 mb-6">
                                        Paste the commands into the MikroTik terminal to auto-connect the router.
                                    </p>
                                    <button
                                        onClick={handleGenerateScript}
                                        disabled={scriptLoading || !selectedUserId}
                                        className="inline-flex items-center px-5 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition-colors"
                                    >
                                        {scriptLoading ? (
                                            <Loader2 className="animate-spin h-4 w-4 mr-2" />
                                        ) : (
                                            <Terminal className="h-4 w-4 mr-2" />
                                        )}
                                        Generate Setup
                                    </button>
                                    {!selectedUserId && (
                                        <p className="text-xs text-amber-600 mt-3">Select a user above first.</p>
                                    )}
                                </div>
                            ) : (
                                <>
                                    {vpnIp && (
                                        <div className="bg-green-50 border border-green-200 rounded-lg p-3 flex items-center gap-2">
                                            <CheckCircle className="h-5 w-5 text-green-600 flex-shrink-0" />
                                            <div>
                                                <span className="text-sm font-semibold text-green-800">VPN IP Assigned: </span>
                                                <span className="text-sm font-mono text-green-700">{vpnIp}</span>
                                            </div>
                                        </div>
                                    )}

                                    <p className="text-sm font-medium text-gray-700">
                                        Run these commands in your MikroTik terminal:
                                    </p>

                                    <div className="space-y-3">
                                        {steps.map((step, i) => (
                                            <div key={i} className="border border-gray-200 rounded-lg overflow-hidden">
                                                <div className="flex items-center justify-between px-3 py-2 bg-gray-50">
                                                    <div className="flex items-center gap-2">
                                                        <span className="flex items-center justify-center w-5 h-5 rounded-full bg-indigo-600 text-white text-[10px] font-bold">
                                                            {i + 1}
                                                        </span>
                                                        <span className="text-xs font-semibold text-gray-800">{step.title}</span>
                                                    </div>
                                                    <button
                                                        onClick={() => copyToClipboard(step.command, i)}
                                                        className="text-gray-400 hover:text-indigo-600 transition-colors p-1"
                                                        title="Copy command"
                                                    >
                                                        {copiedIdx === i ? (
                                                            <CheckCircle className="h-4 w-4 text-green-500" />
                                                        ) : (
                                                            <Copy className="h-4 w-4" />
                                                        )}
                                                    </button>
                                                </div>
                                                <p className="text-[11px] text-gray-500 px-3 pt-1">{step.description}</p>
                                                <pre className="px-3 py-2 text-[11px] font-mono text-gray-800 bg-gray-100 overflow-x-auto whitespace-pre-wrap break-all select-all">
                                                    {step.command}
                                                </pre>
                                            </div>
                                        ))}
                                    </div>

                                    <button
                                        onClick={copyAllCommands}
                                        className="w-full flex items-center justify-center gap-2 px-4 py-2.5 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 transition-colors"
                                    >
                                        {copiedIdx === -1 ? (
                                            <CheckCircle className="h-4 w-4" />
                                        ) : (
                                            <ClipboardCopy className="h-4 w-4" />
                                        )}
                                        {copiedIdx === -1 ? 'Copied!' : 'Copy All Commands'}
                                    </button>

                                    <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
                                        <p className="text-xs font-semibold text-amber-800 mb-1">Important</p>
                                        <p className="text-xs text-amber-700">
                                            Run all commands in order on the MikroTik terminal. The router will auto-register
                                            with Wassal after the last command executes. Requires RouterOS v7+ with WireGuard support.
                                        </p>
                                    </div>
                                </>
                            )}
                        </div>
                    )}
                </div>

                {/* Footer (only for manual tab / edit) */}
                {activeTab === 'manual' && (
                    <div className="flex justify-end p-4 border-t border-gray-200 bg-gray-50">
                        <button
                            type="button" onClick={onClose}
                            className="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit" form="manual-form"
                            disabled={loading}
                            className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md hover:bg-indigo-700 flex items-center"
                        >
                            {loading && <Loader2 className="animate-spin -ml-1 mr-2 h-4 w-4" />}
                            <Save className="h-4 w-4 mr-2" />
                            Save Router
                        </button>
                    </div>
                )}

                {/* Footer for script tab when steps are shown */}
                {activeTab === 'script' && steps.length > 0 && (
                    <div className="flex justify-end p-4 border-t border-gray-200 bg-gray-50">
                        <button
                            type="button" onClick={onClose}
                            className="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50"
                        >
                            Done
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}
