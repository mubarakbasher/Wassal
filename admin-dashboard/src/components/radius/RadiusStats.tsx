import { useState, useEffect } from 'react';
import { Users, Activity, Server, Database } from 'lucide-react';
import api from '../../lib/axios';

interface RadiusStatus {
    status: string;
    tables: {
        users: number;
        groups: number;
        nasClients: number;
        activeSessions: number;
        authLogs: number;
    };
}

export function RadiusStats() {
    const [data, setData] = useState<RadiusStatus | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(false);

    useEffect(() => {
        const fetchStatus = async () => {
            try {
                const response = await api.get('/radius/status');
                setData(response.data);
                setError(false);
            } catch (err) {
                console.error('Failed to fetch RADIUS status:', err);
                setError(true);
            } finally {
                setLoading(false);
            }
        };

        fetchStatus();
        // Refresh every 30 seconds
        const interval = setInterval(fetchStatus, 30000);
        return () => clearInterval(interval);
    }, []);

    if (loading) {
        return <div className="animate-pulse bg-gray-200 h-32 rounded-lg"></div>;
    }

    if (error || !data) {
        return (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
                {['Online Users', 'RADIUS Users', 'NAS Clients', 'Auth Logs'].map((label) => (
                    <div key={label} className="bg-white overflow-hidden shadow rounded-lg">
                        <div className="p-5">
                            <div className="flex items-center">
                                <div className="flex-shrink-0">
                                    <Activity className="h-6 w-6 text-red-300" />
                                </div>
                                <div className="ml-5 w-0 flex-1">
                                    <dl>
                                        <dt className="text-sm font-medium text-gray-500 truncate">{label}</dt>
                                        <dd className="text-sm text-red-500">Unavailable</dd>
                                    </dl>
                                </div>
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        );
    }

    return (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
            <div className="bg-white overflow-hidden shadow rounded-lg">
                <div className="p-5">
                    <div className="flex items-center">
                        <div className="flex-shrink-0">
                            <Users className="h-6 w-6 text-gray-400" />
                        </div>
                        <div className="ml-5 w-0 flex-1">
                            <dl>
                                <dt className="text-sm font-medium text-gray-500 truncate">Online Users</dt>
                                <dd className="text-lg font-medium text-gray-900">{data.tables.activeSessions}</dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
                <div className="p-5">
                    <div className="flex items-center">
                        <div className="flex-shrink-0">
                            <Database className="h-6 w-6 text-gray-400" />
                        </div>
                        <div className="ml-5 w-0 flex-1">
                            <dl>
                                <dt className="text-sm font-medium text-gray-500 truncate">Total Users</dt>
                                <dd className="text-lg font-medium text-gray-900">{data.tables.users}</dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
                <div className="p-5">
                    <div className="flex items-center">
                        <div className="flex-shrink-0">
                            <Server className="h-6 w-6 text-gray-400" />
                        </div>
                        <div className="ml-5 w-0 flex-1">
                            <dl>
                                <dt className="text-sm font-medium text-gray-500 truncate">NAS Clients</dt>
                                <dd className="text-lg font-medium text-gray-900">{data.tables.nasClients}</dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
                <div className="p-5">
                    <div className="flex items-center">
                        <div className="flex-shrink-0">
                            <Activity className="h-6 w-6 text-gray-400" />
                        </div>
                        <div className="ml-5 w-0 flex-1">
                            <dl>
                                <dt className="text-sm font-medium text-gray-500 truncate">Auth Logs</dt>
                                <dd className="text-lg font-medium text-gray-900">{data.tables.authLogs}</dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
