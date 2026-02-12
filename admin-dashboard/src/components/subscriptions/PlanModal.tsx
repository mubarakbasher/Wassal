import { useState, useEffect } from 'react';
import { X } from 'lucide-react';

interface PlanModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (data: any) => Promise<void>;
    initialData?: any;
}

export function PlanModal({ isOpen, onClose, onSubmit, initialData }: PlanModalProps) {
    const [formData, setFormData] = useState({
        name: '',
        price: '',
        durationMonths: 1,
        maxRouters: 1,
        maxHotspotUsers: 0,
        allowReports: true,
        description: ''
    });
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (initialData) {
            setFormData({
                name: initialData.name,
                price: initialData.price,
                durationMonths: initialData.durationDays ? initialData.durationDays / 30 : 1,
                maxRouters: initialData.maxRouters,
                maxHotspotUsers: initialData.maxHotspotUsers,
                allowReports: initialData.allowReports,
                description: initialData.description || ''
            });
        } else {
            setFormData({
                name: '',
                price: '',
                durationMonths: 1,
                maxRouters: 1,
                maxHotspotUsers: 0,
                allowReports: true,
                description: ''
            });
        }
    }, [initialData, isOpen]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        try {
            const payload = {
                name: formData.name,
                price: Number(formData.price),
                durationDays: Number(formData.durationMonths) * 30,
                maxRouters: Number(formData.maxRouters),
                maxHotspotUsers: Number(formData.maxHotspotUsers),
                allowReports: formData.allowReports,
                description: formData.description
            };
            await onSubmit(payload);
            onClose();
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
            <div className="bg-white rounded-xl shadow-xl w-full max-w-lg mx-4 overflow-hidden">
                <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
                    <h3 className="text-lg font-bold text-gray-800">
                        {initialData ? 'Edit Plan' : 'Create New Plan'}
                    </h3>
                    <button onClick={onClose} className="p-1 hover:bg-gray-100 rounded-full">
                        <X className="w-5 h-5 text-gray-500" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Plan Name</label>
                        <input
                            type="text"
                            required
                            value={formData.name}
                            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                            placeholder="e.g. Pro Plan"
                        />
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Price ($)</label>
                            <input
                                type="number"
                                required
                                min="0"
                                step="0.01"
                                value={formData.price}
                                onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Duration (Months)</label>
                            <input
                                type="number"
                                required
                                min="1"
                                value={formData.durationMonths}
                                onChange={(e) => setFormData({ ...formData, durationMonths: Number(e.target.value) })}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                            />
                        </div>
                    </div>

                    <div className="grid grid-cols-2 gap-4">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Max Routers</label>
                            <input
                                type="number"
                                required
                                min="1"
                                value={formData.maxRouters}
                                onChange={(e) => setFormData({ ...formData, maxRouters: Number(e.target.value) })}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1">Max Hotspot Users</label>
                            <input
                                type="number"
                                required
                                min="0"
                                value={formData.maxHotspotUsers}
                                onChange={(e) => setFormData({ ...formData, maxHotspotUsers: Number(e.target.value) })}
                                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                            />
                            <p className="text-xs text-gray-500 mt-1">0 for Unlimited</p>
                        </div>
                    </div>

                    <div className="flex items-center pb-2">
                        <label className="flex items-center space-x-2 cursor-pointer">
                            <input
                                type="checkbox"
                                checked={formData.allowReports}
                                onChange={(e) => setFormData({ ...formData, allowReports: e.target.checked })}
                                className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500"
                            />
                            <span className="text-sm font-medium text-gray-700">Allow Reports</span>
                        </label>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                        <textarea
                            value={formData.description}
                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none h-24 resize-none"
                            placeholder="Plan details..."
                        />
                    </div>

                    <div className="flex justify-end pt-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="mr-3 px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50"
                        >
                            {loading ? 'Saving...' : (initialData ? 'Update Plan' : 'Create Plan')}
                        </button>
                    </div>
                </form>
            </div >
        </div >
    );
}
