import { useState, useEffect } from 'react';
import { User, Lock, Save, CheckCircle } from 'lucide-react';
import api from '../lib/axios';

export function SettingsPage() {
    const [profile, setProfile] = useState({ name: '', email: '', role: '' });
    const [passwords, setPasswords] = useState({ currentPassword: '', newPassword: '', confirmPassword: '' });
    const [profileLoading, setProfileLoading] = useState(false);
    const [passwordLoading, setPasswordLoading] = useState(false);
    const [profileMsg, setProfileMsg] = useState('');
    const [passwordMsg, setPasswordMsg] = useState('');
    const [passwordError, setPasswordError] = useState('');

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            const { data } = await api.get('/admin/system/profile');
            setProfile({ name: data.name, email: data.email, role: data.role });
        } catch (e) {
            console.error('Failed to fetch admin profile', e);
        }
    };

    const handleProfileSave = async (e: React.FormEvent) => {
        e.preventDefault();
        setProfileLoading(true);
        setProfileMsg('');
        try {
            await api.patch('/admin/system/profile', {
                name: profile.name,
                email: profile.email,
            });
            setProfileMsg('Profile updated successfully');
            // Update stored admin info
            const stored = localStorage.getItem('admin_user');
            if (stored) {
                const admin = JSON.parse(stored);
                admin.name = profile.name;
                admin.email = profile.email;
                localStorage.setItem('admin_user', JSON.stringify(admin));
            }
        } catch (err: any) {
            setProfileMsg(err.response?.data?.message || 'Failed to update profile');
        } finally {
            setProfileLoading(false);
        }
    };

    const handlePasswordChange = async (e: React.FormEvent) => {
        e.preventDefault();
        setPasswordError('');
        setPasswordMsg('');

        if (passwords.newPassword !== passwords.confirmPassword) {
            setPasswordError('New passwords do not match');
            return;
        }

        if (passwords.newPassword.length < 8) {
            setPasswordError('Password must be at least 8 characters');
            return;
        }

        setPasswordLoading(true);
        try {
            await api.patch('/admin/system/change-password', {
                currentPassword: passwords.currentPassword,
                newPassword: passwords.newPassword,
            });
            setPasswordMsg('Password changed successfully');
            setPasswords({ currentPassword: '', newPassword: '', confirmPassword: '' });
        } catch (err: any) {
            setPasswordError(err.response?.data?.message || 'Failed to change password');
        } finally {
            setPasswordLoading(false);
        }
    };

    return (
        <div>
            <h1 className="text-2xl font-bold text-gray-800 mb-6">Settings</h1>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Profile Section */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                    <div className="flex items-center mb-6">
                        <div className="p-2 bg-indigo-50 rounded-lg mr-3">
                            <User className="w-5 h-5 text-indigo-600" />
                        </div>
                        <h2 className="text-lg font-semibold text-gray-800">Admin Profile</h2>
                    </div>

                    <form onSubmit={handleProfileSave} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                            <input
                                type="text"
                                value={profile.name}
                                onChange={(e) => setProfile({ ...profile, name: e.target.value })}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Email</label>
                            <input
                                type="email"
                                value={profile.email}
                                onChange={(e) => setProfile({ ...profile, email: e.target.value })}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Role</label>
                            <input
                                type="text"
                                value={profile.role}
                                disabled
                                className="w-full px-4 py-2 bg-gray-50 border border-gray-200 rounded-lg text-gray-500 cursor-not-allowed"
                            />
                        </div>

                        {profileMsg && (
                            <div className="flex items-center text-sm text-green-600 bg-green-50 p-3 rounded-lg">
                                <CheckCircle className="w-4 h-4 mr-2" />
                                {profileMsg}
                            </div>
                        )}

                        <button
                            type="submit"
                            disabled={profileLoading}
                            className="flex items-center px-4 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:opacity-50 transition-colors"
                        >
                            <Save className="w-4 h-4 mr-2" />
                            {profileLoading ? 'Saving...' : 'Save Profile'}
                        </button>
                    </form>
                </div>

                {/* Password Section */}
                <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
                    <div className="flex items-center mb-6">
                        <div className="p-2 bg-red-50 rounded-lg mr-3">
                            <Lock className="w-5 h-5 text-red-600" />
                        </div>
                        <h2 className="text-lg font-semibold text-gray-800">Change Password</h2>
                    </div>

                    <form onSubmit={handlePasswordChange} className="space-y-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Current Password</label>
                            <input
                                type="password"
                                value={passwords.currentPassword}
                                onChange={(e) => setPasswords({ ...passwords, currentPassword: e.target.value })}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                                required
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">New Password</label>
                            <input
                                type="password"
                                value={passwords.newPassword}
                                onChange={(e) => setPasswords({ ...passwords, newPassword: e.target.value })}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                                required
                                minLength={8}
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Confirm New Password</label>
                            <input
                                type="password"
                                value={passwords.confirmPassword}
                                onChange={(e) => setPasswords({ ...passwords, confirmPassword: e.target.value })}
                                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:outline-none"
                                required
                                minLength={8}
                            />
                        </div>

                        {passwordError && (
                            <div className="text-sm text-red-600 bg-red-50 p-3 rounded-lg">
                                {passwordError}
                            </div>
                        )}

                        {passwordMsg && (
                            <div className="flex items-center text-sm text-green-600 bg-green-50 p-3 rounded-lg">
                                <CheckCircle className="w-4 h-4 mr-2" />
                                {passwordMsg}
                            </div>
                        )}

                        <button
                            type="submit"
                            disabled={passwordLoading}
                            className="flex items-center px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 transition-colors"
                        >
                            <Lock className="w-4 h-4 mr-2" />
                            {passwordLoading ? 'Changing...' : 'Change Password'}
                        </button>
                    </form>
                </div>
            </div>
        </div>
    );
}
