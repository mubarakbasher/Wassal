import { useState, useEffect } from 'react';
import { CreditCard, Plus, Check, X, Trash2, Edit2 } from 'lucide-react';
import api from '../lib/axios';
import { Badge } from '../components/ui/Badge';
import { PlanModal } from '../components/subscriptions/PlanModal';

export function SubscriptionsPage() {
    const [plans, setPlans] = useState<any[]>([]);
    const [subscriptions, setSubscriptions] = useState<any[]>([]);
    const [, setLoading] = useState(true);

    // Modal State
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [selectedPlan, setSelectedPlan] = useState<any>(null);

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            const [plansRes, subsRes] = await Promise.all([
                api.get('/admin/subscriptions/plans'),
                api.get('/admin/subscriptions?limit=5') // Recent subs
            ]);
            setPlans(plansRes.data);
            setSubscriptions(subsRes.data.data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleCreate = () => {
        setSelectedPlan(null);
        setIsModalOpen(true);
    };

    const handleEdit = (plan: any) => {
        setSelectedPlan(plan);
        setIsModalOpen(true);
    };

    const handleDelete = async (id: string) => {
        if (!window.confirm('Are you sure you want to delete this plan?')) return;
        try {
            await api.delete(`/admin/subscriptions/plans/${id}`);
            fetchData();
        } catch (error: any) {
            alert(error.response?.data?.message || 'Failed to delete plan');
        }
    };

    const handleFormSubmit = async (data: any) => {
        try {
            if (selectedPlan) {
                await api.patch(`/admin/subscriptions/plans/${selectedPlan.id}`, data);
            } else {
                await api.post('/admin/subscriptions/plans', data);
            }
            fetchData();
        } catch (error: any) {
            alert(error.response?.data?.message || 'Operation failed');
            throw error;
        }
    };

    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800">Subscriptions & Plans</h1>
            </div>

            {/* Plans Section */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">
                {plans.map((plan) => (
                    <div key={plan.id} className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 relative group">
                        <div className="absolute top-4 right-4 flex space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
                            <button
                                onClick={() => handleEdit(plan)}
                                className="p-1.5 text-blue-600 bg-blue-50 rounded-lg hover:bg-blue-100"
                            >
                                <Edit2 className="w-4 h-4" />
                            </button>
                            <button
                                onClick={() => handleDelete(plan.id)}
                                className="p-1.5 text-red-600 bg-red-50 rounded-lg hover:bg-red-100"
                            >
                                <Trash2 className="w-4 h-4" />
                            </button>
                        </div>

                        <div className="flex justify-between items-start mb-4">
                            <div>
                                <h3 className="text-lg font-semibold text-gray-900">{plan.name}</h3>
                                <p className="text-2xl font-bold text-indigo-600">
                                    ${plan.price}
                                    <span className="text-sm font-normal text-gray-500 ml-1">
                                        / {(plan.durationDays || 30) / 30} Month{(plan.durationDays || 30) / 30 > 1 ? 's' : ''}
                                    </span>
                                </p>
                            </div>
                            <div className="p-2 bg-indigo-50 rounded-lg">
                                <CreditCard className="w-5 h-5 text-indigo-600" />
                            </div>
                        </div>

                        <ul className="space-y-3 mb-6">
                            <li className="flex items-center text-sm text-gray-600">
                                <Check className="w-4 h-4 text-green-500 mr-2" />
                                {plan.maxRouters} Router(s)
                            </li>
                            <li className="flex items-center text-sm text-gray-600">
                                <Check className="w-4 h-4 text-green-500 mr-2" />
                                {plan.maxHotspotUsers === 0 ? 'Unlimited' : plan.maxHotspotUsers} Hotspot Users
                            </li>
                            <li className="flex items-center text-sm text-gray-600">
                                {plan.allowReports ? <Check className="w-4 h-4 text-green-500 mr-2" /> : <X className="w-4 h-4 text-red-500 mr-2" />}
                                Reports
                            </li>
                        </ul>
                    </div>
                ))}

                <div
                    onClick={handleCreate}
                    className="border-2 border-dashed border-gray-200 rounded-xl p-6 flex flex-col items-center justify-center cursor-pointer hover:border-indigo-300 hover:bg-indigo-50 transition-all min-h-[250px]"
                >
                    <div className="p-3 bg-white rounded-full shadow-sm mb-3">
                        <Plus className="w-6 h-6 text-indigo-600" />
                    </div>
                    <span className="font-medium text-gray-600">Create New Plan</span>
                </div>
            </div>

            {/* Recent Subscriptions */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100">
                <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center">
                    <h3 className="font-semibold text-gray-800">Recent User Subscriptions</h3>
                </div>
                <table className="w-full text-left">
                    <thead className="bg-gray-50 border-b border-gray-100">
                        <tr>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">User</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Plan</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Status</th>
                            <th className="px-6 py-3 text-xs font-semibold text-gray-500 uppercase">Expires</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                        {subscriptions.length === 0 ? (
                            <tr><td colSpan={4} className="px-6 py-8 text-center text-gray-500">No active subscriptions found</td></tr>
                        ) : (
                            subscriptions.map((sub) => (
                                <tr key={sub.id}>
                                    <td className="px-6 py-4">
                                        <div className="font-medium text-gray-900">{sub.user?.name || 'Unknown'}</div>
                                        <div className="text-sm text-gray-500">{sub.user?.email}</div>
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-600">{sub.plan.name}</td>
                                    <td className="px-6 py-4">
                                        <Badge variant={sub.status === 'ACTIVE' ? 'success' : 'warning'}>{sub.status}</Badge>
                                    </td>
                                    <td className="px-6 py-4 text-sm text-gray-500">
                                        {new Date(sub.expiresAt).toLocaleDateString()}
                                    </td>
                                </tr>
                            ))
                        )}
                    </tbody>
                </table>
            </div>

            <PlanModal
                isOpen={isModalOpen}
                onClose={() => setIsModalOpen(false)}
                onSubmit={handleFormSubmit}
                initialData={selectedPlan}
            />
        </div>
    );
}
