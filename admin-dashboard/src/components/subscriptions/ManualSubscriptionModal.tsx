import { useState, useEffect } from 'react';
import { X, Calendar, Package } from 'lucide-react';
import api from '../../lib/axios';

interface Plan {
    id: string;
    name: string;
    price: string;
    durationDays: number;
}

interface ManualSubscriptionModalProps {
    isOpen: boolean;
    onClose: () => void;
    userId: string;
    onSuccess: () => void;
}

export function ManualSubscriptionModal({ isOpen, onClose, userId, onSuccess }: ManualSubscriptionModalProps) {
    const [plans, setPlans] = useState<Plan[]>([]);
    const [selectedPlanId, setSelectedPlanId] = useState('');
    const [durationDays, setDurationDays] = useState('');
    const [loading, setLoading] = useState(false);
    const [fetchingPlans, setFetchingPlans] = useState(true);

    useEffect(() => {
        if (isOpen) {
            const fetchPlans = async () => {
                setFetchingPlans(true);
                try {
                    const { data } = await api.get('/admin/subscriptions/plans');
                    setPlans(data);
                    if (data.length > 0) setSelectedPlanId(data[0].id);
                } catch (error) {
                    console.error('Failed to fetch plans', error);
                } finally {
                    setFetchingPlans(false);
                }
            };
            fetchPlans();
        }
    }, [isOpen]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!selectedPlanId) return;

        setLoading(true);
        try {
            await api.post('/admin/subscriptions/assign', {
                userId,
                planId: selectedPlanId,
                durationDays: durationDays ? parseInt(durationDays) : undefined
            });
            onSuccess();
            onClose();
        } catch (error: any) {
            alert(error.response?.data?.message || 'Failed to assign subscription');
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
            <div className="bg-white rounded-xl shadow-xl w-full max-w-md mx-4 overflow-hidden">
                <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
                    <h3 className="text-lg font-bold text-gray-800">Assign Subscription</h3>
                    <button onClick={onClose} className="p-1 hover:bg-gray-100 rounded-full">
                        <X className="w-5 h-5 text-gray-500" />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {fetchingPlans ? (
                        <div className="text-center py-4 text-gray-500">Loading plans...</div>
                    ) : (
                        <>
                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">Select Plan</label>
                                <div className="relative">
                                    <Package className="w-5 h-5 text-gray-400 absolute left-3 top-2.5" />
                                    <select
                                        value={selectedPlanId}
                                        onChange={(e) => setSelectedPlanId(e.target.value)}
                                        className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none bg-white"
                                    >
                                        {plans.map(plan => (
                                            <option key={plan.id} value={plan.id}>
                                                {plan.name} (${Number(plan.price).toFixed(2)} / {plan.durationDays} days)
                                            </option>
                                        ))}
                                    </select>
                                </div>
                            </div>

                            <div>
                                <label className="block text-sm font-medium text-gray-700 mb-1">
                                    Custom Duration (Days)
                                    <span className="text-xs font-normal text-gray-500 ml-1">(Optional override)</span>
                                </label>
                                <div className="relative">
                                    <Calendar className="w-5 h-5 text-gray-400 absolute left-3 top-2.5" />
                                    <input
                                        type="number"
                                        min="1"
                                        value={durationDays}
                                        onChange={(e) => setDurationDays(e.target.value)}
                                        className="w-full pl-10 pr-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"
                                        placeholder="Use plan default"
                                    />
                                </div>
                            </div>

                            <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-3 text-xs text-yellow-800">
                                Warning: Assigning a new subscription will expire any currently active subscription for this user.
                            </div>
                        </>
                    )}

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
                            disabled={loading || fetchingPlans || !selectedPlanId}
                            className="px-4 py-2 text-sm font-medium text-white bg-indigo-600 rounded-lg hover:bg-indigo-700 disabled:opacity-50"
                        >
                            {loading ? 'Assigning...' : 'Assign Plan'}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
