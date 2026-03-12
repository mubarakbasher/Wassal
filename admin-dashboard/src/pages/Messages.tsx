import { useState, useEffect } from 'react';
import { MessageSquare, Send, Search, ChevronDown, ChevronUp, Mail, MailOpen, CheckCheck } from 'lucide-react';
import api from '../lib/axios';
import { Badge } from '../components/ui/Badge';

interface ContactMessage {
    id: string;
    subject: string;
    message: string;
    status: 'UNREAD' | 'READ' | 'REPLIED';
    reply: string | null;
    repliedAt: string | null;
    createdAt: string;
    user: { id: string; email: string; name: string | null };
}

export function MessagesPage() {
    const [messages, setMessages] = useState<ContactMessage[]>([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('ALL');
    const [search, setSearch] = useState('');
    const [expandedId, setExpandedId] = useState<string | null>(null);
    const [replyText, setReplyText] = useState('');
    const [replying, setReplying] = useState(false);
    const [page, setPage] = useState(1);
    const [meta, setMeta] = useState<{ total: number; lastPage: number }>({ total: 0, lastPage: 1 });

    useEffect(() => {
        fetchMessages();
    }, [filter, page, search]);

    const fetchMessages = async () => {
        setLoading(true);
        try {
            const { data } = await api.get('/admin/messages', {
                params: { status: filter === 'ALL' ? undefined : filter, page, search: search || undefined },
            });
            setMessages(data.data);
            setMeta(data.meta);
        } catch (e) {
            console.error(e);
        } finally {
            setLoading(false);
        }
    };

    const handleExpand = async (msg: ContactMessage) => {
        if (expandedId === msg.id) {
            setExpandedId(null);
            setReplyText('');
            return;
        }
        setExpandedId(msg.id);
        setReplyText(msg.reply || '');

        if (msg.status === 'UNREAD') {
            try {
                await api.patch(`/admin/messages/${msg.id}/read`);
                setMessages(prev =>
                    prev.map(m => m.id === msg.id ? { ...m, status: 'READ' } : m)
                );
            } catch (e) {
                console.error(e);
            }
        }
    };

    const handleReply = async (id: string) => {
        if (!replyText.trim()) return;
        setReplying(true);
        try {
            await api.patch(`/admin/messages/${id}/reply`, { reply: replyText.trim() });
            setMessages(prev =>
                prev.map(m => m.id === id ? { ...m, status: 'REPLIED', reply: replyText.trim(), repliedAt: new Date().toISOString() } : m)
            );
            setExpandedId(null);
            setReplyText('');
        } catch (e) {
            alert('Failed to send reply');
        } finally {
            setReplying(false);
        }
    };

    const statusIcon = (status: string) => {
        switch (status) {
            case 'UNREAD': return <Mail className="w-4 h-4 text-yellow-600" />;
            case 'READ': return <MailOpen className="w-4 h-4 text-blue-600" />;
            case 'REPLIED': return <CheckCheck className="w-4 h-4 text-green-600" />;
            default: return null;
        }
    };

    const statusVariant = (status: string): 'warning' | 'info' | 'success' | 'default' => {
        switch (status) {
            case 'UNREAD': return 'warning';
            case 'READ': return 'info';
            case 'REPLIED': return 'success';
            default: return 'default';
        }
    };

    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <div className="flex items-center space-x-3">
                    <MessageSquare className="w-7 h-7 text-indigo-600" />
                    <h1 className="text-2xl font-bold text-gray-800">Messages</h1>
                    {meta.total > 0 && (
                        <span className="text-sm text-gray-500">({meta.total} total)</span>
                    )}
                </div>
                <div className="flex items-center space-x-2">
                    <div className="relative">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                        <input
                            type="text"
                            placeholder="Search messages..."
                            value={search}
                            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
                            className="pl-9 pr-4 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-200 w-56"
                        />
                    </div>
                    {(['ALL', 'UNREAD', 'READ', 'REPLIED'] as const).map((status) => (
                        <button
                            key={status}
                            onClick={() => { setFilter(status); setPage(1); }}
                            className={`px-4 py-2 text-sm font-medium rounded-lg border transition-colors ${filter === status
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
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Subject</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Status</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Date</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase text-right">Details</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {loading ? (
                            <tr><td colSpan={5} className="px-6 py-8 text-center text-gray-500">Loading...</td></tr>
                        ) : messages.length === 0 ? (
                            <tr><td colSpan={5} className="px-6 py-8 text-center text-gray-500">No messages found</td></tr>
                        ) : (
                            messages.map((msg) => (
                                <MessageRow
                                    key={msg.id}
                                    msg={msg}
                                    isExpanded={expandedId === msg.id}
                                    onExpand={() => handleExpand(msg)}
                                    replyText={replyText}
                                    onReplyChange={setReplyText}
                                    onReply={() => handleReply(msg.id)}
                                    replying={replying}
                                    statusIcon={statusIcon}
                                    statusVariant={statusVariant}
                                />
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            {meta.lastPage > 1 && (
                <div className="flex justify-center items-center space-x-2 mt-4">
                    <button
                        onClick={() => setPage(p => Math.max(1, p - 1))}
                        disabled={page === 1}
                        className="px-3 py-1 text-sm border border-gray-200 rounded-lg disabled:opacity-50 hover:bg-gray-50"
                    >
                        Previous
                    </button>
                    <span className="text-sm text-gray-600">Page {page} of {meta.lastPage}</span>
                    <button
                        onClick={() => setPage(p => Math.min(meta.lastPage, p + 1))}
                        disabled={page === meta.lastPage}
                        className="px-3 py-1 text-sm border border-gray-200 rounded-lg disabled:opacity-50 hover:bg-gray-50"
                    >
                        Next
                    </button>
                </div>
            )}
        </div>
    );
}

function MessageRow({
    msg,
    isExpanded,
    onExpand,
    replyText,
    onReplyChange,
    onReply,
    replying,
    statusIcon,
    statusVariant,
}: {
    msg: ContactMessage;
    isExpanded: boolean;
    onExpand: () => void;
    replyText: string;
    onReplyChange: (v: string) => void;
    onReply: () => void;
    replying: boolean;
    statusIcon: (s: string) => React.ReactNode;
    statusVariant: (s: string) => 'warning' | 'info' | 'success' | 'default';
}) {
    return (
        <>
            <tr
                className={`cursor-pointer transition-colors ${msg.status === 'UNREAD' ? 'bg-indigo-50/40 font-medium' : 'hover:bg-gray-50'}`}
                onClick={onExpand}
            >
                <td className="px-6 py-4">
                    <div className={`text-gray-900 ${msg.status === 'UNREAD' ? 'font-semibold' : 'font-medium'}`}>
                        {msg.user?.name || 'Unknown'}
                    </div>
                    <div className="text-sm text-gray-500">{msg.user?.email}</div>
                </td>
                <td className="px-6 py-4">
                    <div className="flex items-center space-x-2">
                        {statusIcon(msg.status)}
                        <span className="text-gray-800">{msg.subject}</span>
                    </div>
                </td>
                <td className="px-6 py-4">
                    <Badge variant={statusVariant(msg.status)}>
                        {msg.status}
                    </Badge>
                </td>
                <td className="px-6 py-4 text-sm text-gray-500">
                    {new Date(msg.createdAt).toLocaleDateString()}
                </td>
                <td className="px-6 py-4 text-right">
                    {isExpanded
                        ? <ChevronUp className="w-5 h-5 text-gray-400 inline" />
                        : <ChevronDown className="w-5 h-5 text-gray-400 inline" />
                    }
                </td>
            </tr>
            {isExpanded && (
                <tr>
                    <td colSpan={5} className="px-6 py-4 bg-gray-50/50">
                        <div className="space-y-4 max-w-3xl">
                            <div>
                                <p className="text-xs font-semibold text-gray-500 uppercase mb-1">Message</p>
                                <p className="text-gray-700 whitespace-pre-wrap">{msg.message}</p>
                            </div>

                            {msg.reply && (
                                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                                    <p className="text-xs font-semibold text-green-700 uppercase mb-1">Admin Reply</p>
                                    <p className="text-green-800 whitespace-pre-wrap">{msg.reply}</p>
                                    {msg.repliedAt && (
                                        <p className="text-xs text-green-600 mt-2">
                                            Replied on {new Date(msg.repliedAt).toLocaleString()}
                                        </p>
                                    )}
                                </div>
                            )}

                            <div>
                                <p className="text-xs font-semibold text-gray-500 uppercase mb-2">
                                    {msg.status === 'REPLIED' ? 'Update Reply' : 'Reply'}
                                </p>
                                <div className="flex space-x-2">
                                    <textarea
                                        value={replyText}
                                        onChange={(e) => onReplyChange(e.target.value)}
                                        placeholder="Type your reply..."
                                        rows={3}
                                        className="flex-1 px-4 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-200 resize-none"
                                    />
                                    <button
                                        onClick={(e) => { e.stopPropagation(); onReply(); }}
                                        disabled={replying || !replyText.trim()}
                                        className="self-end px-4 py-2 bg-indigo-600 text-white text-sm font-medium rounded-lg hover:bg-indigo-700 disabled:opacity-50 flex items-center space-x-1 transition-colors"
                                    >
                                        <Send className="w-4 h-4" />
                                        <span>{replying ? 'Sending...' : 'Send'}</span>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </td>
                </tr>
            )}
        </>
    );
}
