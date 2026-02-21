import { useState } from 'react';
import { Plus } from 'lucide-react';
import { RouterList } from '../components/routers/RouterList';
import { RouterForm } from '../components/routers/RouterForm';

export function RoutersPage() {
    const [isFormOpen, setIsFormOpen] = useState(false);
    const [editingRouter, setEditingRouter] = useState<any>(null);
    const [refreshKey, setRefreshKey] = useState(0);

    const handleAddClick = () => {
        setEditingRouter(null);
        setIsFormOpen(true);
    };

    const handleEditClick = (router: any) => {
        setEditingRouter(router);
        setIsFormOpen(true);
    };

    const handleSave = () => {
        setRefreshKey(prev => prev + 1); // Trigger refresh in list by re-mounting or custom prop
        // In this simple version, RouterList handles its own fetching on mount/delete
        // We might need to lift state up or use a context/query library for better UX
        // For now, let's force a reload by re-rendering RouterList
        window.location.reload(); // Simple but effective for v1
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Router Management</h1>
                    <p className="mt-1 text-sm text-gray-500">
                        Monitor and configure your MikroTik routers.
                    </p>
                </div>
                <button
                    onClick={handleAddClick}
                    className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700"
                >
                    <Plus className="-ml-1 mr-2 h-5 w-5" />
                    Add Router
                </button>
            </div>

            <RouterList key={refreshKey} onEdit={handleEditClick} />

            {isFormOpen && (
                <RouterForm
                    initialData={editingRouter}
                    onClose={() => setIsFormOpen(false)}
                    onSave={handleSave}
                />
            )}
        </div>
    );
}
