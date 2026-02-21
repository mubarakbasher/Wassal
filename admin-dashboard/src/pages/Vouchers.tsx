import { useState } from 'react';
import { Plus } from 'lucide-react';
import { VoucherList } from '../components/vouchers/VoucherList';
import { VoucherGenerator } from '../components/vouchers/VoucherGenerator';

export function VouchersPage() {
    const [isGeneratorOpen, setIsGeneratorOpen] = useState(false);
    const [refreshKey, setRefreshKey] = useState(0);

    const handleSuccess = () => {
        setRefreshKey(prev => prev + 1);
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Voucher Management</h1>
                    <p className="mt-1 text-sm text-gray-500">
                        Generate and manage Wi-Fi vouchers.
                    </p>
                </div>
                <button
                    onClick={() => setIsGeneratorOpen(true)}
                    className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
                >
                    <Plus className="-ml-1 mr-2 h-5 w-5" />
                    Generate Vouchers
                </button>
            </div>

            <VoucherList key={refreshKey} />

            {isGeneratorOpen && (
                <VoucherGenerator
                    onClose={() => setIsGeneratorOpen(false)}
                    onSuccess={handleSuccess}
                />
            )}
        </div>
    );
}
