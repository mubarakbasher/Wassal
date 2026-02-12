import React from 'react';
import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard,
    Users,
    CreditCard,
    Settings,
    ShieldAlert,
    LogOut,
    Activity
} from 'lucide-react';
import { clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: (string | undefined | null | false)[]) {
    return twMerge(clsx(inputs));
}

export function Sidebar() {
    const navItems = [
        { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
        { icon: Users, label: 'Users', path: '/users' },
        { icon: CreditCard, label: 'Subscriptions', path: '/subscriptions' },
        { icon: CreditCard, label: 'Payments', path: '/payments' },
        { icon: Activity, label: 'System', path: '/system' },
        { icon: Settings, label: 'Settings', path: '/settings' },
    ];

    const handleLogout = () => {
        localStorage.removeItem('admin_token');
        window.location.href = '/login';
    };

    return (
        <div className="flex flex-col w-64 h-screen bg-white border-r border-gray-200">
            <div className="flex items-center justify-center h-16 border-b border-gray-200">
                <h1 className="text-xl font-bold text-indigo-600">Wassal Admin</h1>
            </div>

            <nav className="flex-1 p-4 space-y-1">
                {navItems.map((item) => (
                    <NavLink
                        key={item.path}
                        to={item.path}
                        className={({ isActive }) => cn(
                            "flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors",
                            isActive
                                ? "bg-indigo-50 text-indigo-700"
                                : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"
                        )}
                    >
                        <item.icon className="w-5 h-5 mr-3" />
                        {item.label}
                    </NavLink>
                ))}
            </nav>

            <div className="p-4 border-t border-gray-200">
                <button
                    onClick={handleLogout}
                    className="flex items-center w-full px-4 py-2 text-sm font-medium text-red-600 rounded-lg hover:bg-red-50"
                >
                    <LogOut className="w-5 h-5 mr-3" />
                    Logout
                </button>
            </div>
        </div>
    );
}
