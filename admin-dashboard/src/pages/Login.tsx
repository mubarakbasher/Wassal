import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Lock } from 'lucide-react';
import api from '../lib/axios';

export function Login() {
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            const response = await api.post('/admin/auth/login', { email, password });
            localStorage.setItem('admin_token', response.data.access_token);
            localStorage.setItem('admin_user', JSON.stringify(response.data.admin));
            navigate('/');
        } catch (err: any) {
            console.error('Login Error:', err);
            if (err.code === 'ERR_NETWORK') {
                setError('Unable to connect to the server. Please ensure the backend is running.');
            } else {
                setError(err.response?.data?.message || 'Login failed. Please check your credentials.');
            }
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex items-center justify-center min-h-screen bg-gray-100">
            <div className="w-full max-w-md p-8 bg-white rounded-lg shadow-lg">
                <div className="flex justify-center mb-6">
                    <div className="p-3 bg-indigo-100 rounded-full">
                        <Lock className="w-8 h-8 text-indigo-600" />
                    </div>
                </div>
                <h2 className="mb-6 text-2xl font-bold text-center text-gray-800">Admin Login</h2>

                {error && (
                    <div className="p-3 mb-4 text-sm text-red-700 bg-red-100 rounded-lg">
                        {error}
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-6">
                    <div>
                        <label className="block mb-2 text-sm font-medium text-gray-700">Email</label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                            placeholder="admin@wassal.com"
                            required
                        />
                    </div>
                    <div>
                        <label className="block mb-2 text-sm font-medium text-gray-700">Password</label>
                        <input
                            type="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                            placeholder="••••••••"
                            required
                        />
                    </div>
                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full py-3 text-white transition-colors bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50"
                    >
                        {loading ? 'Logging in...' : 'Sign In'}
                    </button>
                </form>
            </div>
        </div>
    );
}
