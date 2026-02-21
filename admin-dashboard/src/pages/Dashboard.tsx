import { useState, useEffect } from 'react';
import { Users, DollarSign, Activity, Clock } from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import api from '../lib/axios';
import { RadiusStats } from '../components/radius/RadiusStats';

const StatCard = ({ title, value, change, icon: Icon, color }: any) => (
    <div className="p-6 bg-white rounded-xl shadow-sm border border-gray-100">
        <div className="flex items-center justify-between">
            <div>
                <p className="text-sm font-medium text-gray-500">{title}</p>
                <p className="mt-2 text-3xl font-bold text-gray-900">{value}</p>
            </div>
            <div className={`p-3 rounded-lg ${color}`}>
                <Icon className="w-6 h-6 text-white" />
            </div>
        </div>
        {change && (
            <div className="mt-4 flex items-center">
                <span className={`text-sm font-medium ${change.startsWith('+') ? 'text-green-600' : 'text-red-600'}`}>
                    {change}
                </span>
                <span className="ml-2 text-sm text-gray-400">vs last period</span>
            </div>
        )}
    </div>
);

export function Dashboard() {
    const [stats, setStats] = useState({
        totalUsers: 0,
        totalRevenue: 0,
        activeSubscriptions: 0
    });
    const [logs, setLogs] = useState<any[]>([]);
    const [revenueData, setRevenueData] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchDashboardData();
    }, []);

    const fetchDashboardData = async () => {
        try {
            const [statsRes, logsRes, revenueRes] = await Promise.all([
                api.get('/admin/system/stats'),
                api.get('/admin/system/audit-logs?limit=5'),
                api.get('/admin/system/revenue-chart'),
            ]);
            setStats(statsRes.data);
            setLogs(logsRes.data.data);
            setRevenueData(revenueRes.data);
        } catch (error) {
            console.error('Failed to fetch dashboard data', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) {
        return <div className="p-8 text-center text-gray-500">Loading dashboard data...</div>;
    }

    return (
        <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-6">Dashboard Overview</h1>

            <RadiusStats />

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                <StatCard
                    title="Total Register Users"
                    value={stats.totalUsers.toLocaleString()}
                    change="+0%"
                    icon={Users}
                    color="bg-blue-500"
                />
                <StatCard
                    title="Total Revenue"
                    value={`$${Number(stats.totalRevenue).toLocaleString()}`}
                    change="+0%"
                    icon={DollarSign}
                    color="bg-green-500"
                />
                <StatCard
                    title="Active Subscriptions"
                    value={stats.activeSubscriptions.toLocaleString()}
                    change="+0%"
                    icon={Activity}
                    color="bg-indigo-500"
                />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Revenue Chart */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 lg:col-span-2">
                    <h2 className="text-lg font-bold text-gray-800 mb-4">Revenue Analytics</h2>
                    <div className="h-72">
                        {revenueData.length > 0 ? (
                            <ResponsiveContainer width="100%" height="100%">
                                <AreaChart data={revenueData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                                    <defs>
                                        <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="5%" stopColor="#6366f1" stopOpacity={0.3} />
                                            <stop offset="95%" stopColor="#6366f1" stopOpacity={0} />
                                        </linearGradient>
                                    </defs>
                                    <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                                    <XAxis
                                        dataKey="month"
                                        tick={{ fontSize: 12, fill: '#9ca3af' }}
                                        axisLine={false}
                                        tickLine={false}
                                    />
                                    <YAxis
                                        tick={{ fontSize: 12, fill: '#9ca3af' }}
                                        axisLine={false}
                                        tickLine={false}
                                        tickFormatter={(v) => `$${v}`}
                                    />
                                    <Tooltip
                                        contentStyle={{
                                            backgroundColor: '#fff',
                                            border: '1px solid #e5e7eb',
                                            borderRadius: '8px',
                                            fontSize: '13px',
                                        }}
                                        formatter={(value: number) => [`$${value.toLocaleString()}`, 'Revenue']}
                                    />
                                    <Area
                                        type="monotone"
                                        dataKey="revenue"
                                        stroke="#6366f1"
                                        strokeWidth={2}
                                        fill="url(#revenueGradient)"
                                    />
                                </AreaChart>
                            </ResponsiveContainer>
                        ) : (
                            <div className="h-full flex items-center justify-center bg-gray-50 rounded-lg border border-dashed border-gray-300">
                                <span className="text-gray-400">No revenue data yet</span>
                            </div>
                        )}
                    </div>
                </div>

                {/* Recent Activity (Audit Logs) */}
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <h2 className="text-lg font-bold text-gray-800 mb-4">Recent Activity</h2>
                    <div className="space-y-4">
                        {logs.length === 0 ? (
                            <p className="text-gray-500 text-sm">No recent activity.</p>
                        ) : (
                            logs.map((log) => (
                                <div key={log.id} className="flex items-start p-3 hover:bg-gray-50 rounded-lg transition-colors border-b border-gray-50 last:border-0">
                                    <div className="p-2 bg-indigo-50 rounded-full mr-3 shrink-0">
                                        <Clock className="w-4 h-4 text-indigo-600" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-medium text-gray-900">
                                            {log.action.replace(/_/g, ' ')}
                                        </p>
                                        <p className="text-xs text-gray-500 mt-1">
                                            {log.admin?.name || log.admin?.email} • {new Date(log.createdAt).toLocaleTimeString()}
                                        </p>
                                    </div>
                                </div>
                            ))
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
