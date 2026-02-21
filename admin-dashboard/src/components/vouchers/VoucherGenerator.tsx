import { useState, useEffect } from 'react';
import { X, Clock, HardDrive, Wifi, Timer, ChevronDown } from 'lucide-react';
import api from '../../lib/axios';

interface Profile {
    id: string;
    name: string;
    rateLimit?: string;
    sharedUsers: number;
}

interface Router {
    id: string;
    name: string;
    profiles?: Profile[];
}

interface VoucherGeneratorProps {
    onClose: () => void;
    onSuccess: () => void;
}

// Time presets for quick selection
const TIME_PRESETS = [
    { label: '30 min', minutes: 30 },
    { label: '1 hour', minutes: 60 },
    { label: '2 hours', minutes: 120 },
    { label: '6 hours', minutes: 360 },
    { label: '12 hours', minutes: 720 },
    { label: '1 day', minutes: 1440 },
    { label: '3 days', minutes: 4320 },
    { label: '7 days', minutes: 10080 },
    { label: '30 days', minutes: 43200 },
];

// Data presets for quick selection
const DATA_PRESETS = [
    { label: '100 MB', bytes: 100 * 1024 * 1024 },
    { label: '500 MB', bytes: 500 * 1024 * 1024 },
    { label: '1 GB', bytes: 1024 * 1024 * 1024 },
    { label: '2 GB', bytes: 2 * 1024 * 1024 * 1024 },
    { label: '5 GB', bytes: 5 * 1024 * 1024 * 1024 },
    { label: '10 GB', bytes: 10 * 1024 * 1024 * 1024 },
    { label: '50 GB', bytes: 50 * 1024 * 1024 * 1024 },
    { label: 'Unlimited', bytes: 0 },
];

type TimeUnit = 'minutes' | 'hours' | 'days';
type DataUnit = 'MB' | 'GB';

export function VoucherGenerator({ onClose, onSuccess }: VoucherGeneratorProps) {
    const [routers, setRouters] = useState<Router[]>([]);
    const [availableProfiles, setAvailableProfiles] = useState<string[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    // Form State
    const [selectedRouterId, setSelectedRouterId] = useState('');
    const [mikrotikProfile, setMikrotikProfile] = useState('');
    const [quantity, setQuantity] = useState(1);
    const [planName, setPlanName] = useState('');
    const [autoName, setAutoName] = useState(true);
    const [price, setPrice] = useState('0');

    // Limit Type
    const [planType, setPlanType] = useState<'TIME_BASED' | 'DATA_BASED'>('TIME_BASED');
    const [countType, setCountType] = useState<'WALL_CLOCK' | 'ONLINE_ONLY'>('ONLINE_ONLY');

    // Time input — user-friendly
    const [timeValue, setTimeValue] = useState(1);
    const [timeUnit, setTimeUnit] = useState<TimeUnit>('hours');
    const [selectedTimePreset, setSelectedTimePreset] = useState<number | null>(60); // 1 hour default

    // Data input — user-friendly
    const [dataValue, setDataValue] = useState(1);
    const [dataUnit, setDataUnit] = useState<DataUnit>('GB');
    const [selectedDataPreset, setSelectedDataPreset] = useState<number | null>(1024 * 1024 * 1024); // 1 GB default

    // Advanced options toggle
    const [showAdvanced, setShowAdvanced] = useState(false);

    // Convert time to minutes
    const getMinutes = () => {
        if (selectedTimePreset !== null) {
            return selectedTimePreset;
        }
        switch (timeUnit) {
            case 'minutes': return timeValue;
            case 'hours': return timeValue * 60;
            case 'days': return timeValue * 1440;
            default: return timeValue;
        }
    };

    // Convert data to bytes
    const getBytes = () => {
        if (selectedDataPreset !== null) {
            return selectedDataPreset;
        }
        switch (dataUnit) {
            case 'MB': return dataValue * 1024 * 1024;
            case 'GB': return dataValue * 1024 * 1024 * 1024;
            default: return dataValue;
        }
    };

    // Auto-generate plan name
    useEffect(() => {
        if (!autoName) return;
        if (planType === 'TIME_BASED') {
            const mins = getMinutes();
            if (mins >= 1440) {
                const days = Math.round(mins / 1440);
                setPlanName(`${days} Day${days > 1 ? 's' : ''} Access`);
            } else if (mins >= 60) {
                const hrs = Math.round(mins / 60);
                setPlanName(`${hrs} Hour${hrs > 1 ? 's' : ''} Access`);
            } else {
                setPlanName(`${mins} Minutes Access`);
            }
        } else {
            const bytes = getBytes();
            if (bytes === 0) {
                setPlanName('Unlimited Data');
            } else if (bytes >= 1024 * 1024 * 1024) {
                const gb = Math.round(bytes / (1024 * 1024 * 1024));
                setPlanName(`${gb} GB Data Plan`);
            } else {
                const mb = Math.round(bytes / (1024 * 1024));
                setPlanName(`${mb} MB Data Plan`);
            }
        }
    }, [planType, timeValue, timeUnit, dataValue, dataUnit, selectedTimePreset, selectedDataPreset, autoName]);

    useEffect(() => {
        const loadRouters = async () => {
            try {
                const res = await api.get('/admin/routers');
                setRouters(res.data);
                if (res.data.length > 0) {
                    setSelectedRouterId(res.data[0].id);
                }
            } catch (e) {
                console.error("Failed to load routers", e);
            }
        };
        loadRouters();
    }, []);

    useEffect(() => {
        if (!selectedRouterId) return;
        const loadProfiles = async () => {
            try {
                const res = await api.get(`/admin/routers/${selectedRouterId}/profiles/mikrotik`);
                setAvailableProfiles(res.data.map((p: any) => p.name));
                if (res.data.length > 0) {
                    setMikrotikProfile(res.data[0].name);
                }
            } catch (e) {
                console.error("Failed to load profiles", e);
                setAvailableProfiles([]);
            }
        };
        loadProfiles();
    }, [selectedRouterId]);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        setSuccess('');

        try {
            const payload: any = {
                routerId: selectedRouterId,
                mikrotikProfile,
                quantity: Number(quantity),
                planName,
                price: Number(price),
                planType,
            };

            if (planType === 'TIME_BASED') {
                payload.countType = countType;
                payload.duration = getMinutes();
            } else {
                payload.dataLimit = getBytes();
            }

            const res = await api.post('/admin/vouchers', payload);
            const count = res.data?.vouchers?.length || quantity;
            setSuccess(`✅ ${count} voucher${count > 1 ? 's' : ''} generated successfully!`);
            onSuccess();
            setTimeout(() => onClose(), 1500);
        } catch (err: any) {
            setError(err?.response?.data?.message || 'Failed to generate vouchers');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl shadow-2xl w-full max-w-lg overflow-hidden animate-in fade-in zoom-in duration-200">
                {/* Header */}
                <div className="bg-gradient-to-r from-indigo-600 to-purple-600 p-5">
                    <div className="flex justify-between items-center">
                        <div>
                            <h3 className="text-lg font-semibold text-white">Generate Vouchers</h3>
                            <p className="text-indigo-200 text-sm mt-0.5">Create new Wi-Fi access vouchers</p>
                        </div>
                        <button
                            onClick={onClose}
                            className="text-white/70 hover:text-white hover:bg-white/10 rounded-lg p-1.5 transition-colors"
                        >
                            <X className="h-5 w-5" />
                        </button>
                    </div>
                </div>

                <form onSubmit={handleSubmit} className="p-5 space-y-5 max-h-[70vh] overflow-y-auto">
                    {/* Router Selection */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">Router</label>
                        <div className="relative">
                            <select
                                className="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors appearance-none pr-10"
                                value={selectedRouterId}
                                onChange={(e) => setSelectedRouterId(e.target.value)}
                                required
                            >
                                {routers.map(router => (
                                    <option key={router.id} value={router.id}>{router.name}</option>
                                ))}
                            </select>
                            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
                        </div>
                    </div>

                    {/* ━━━━━━━━━━━━━━ Limit Type Toggle ━━━━━━━━━━━━━━ */}
                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-2">Limit Type</label>
                        <div className="grid grid-cols-2 gap-3">
                            <button
                                type="button"
                                onClick={() => setPlanType('TIME_BASED')}
                                className={`relative flex flex-col items-center gap-2 p-4 rounded-xl border-2 transition-all duration-200 ${planType === 'TIME_BASED'
                                        ? 'border-indigo-500 bg-indigo-50 text-indigo-700 shadow-md shadow-indigo-500/10'
                                        : 'border-gray-200 bg-white text-gray-500 hover:border-gray-300 hover:bg-gray-50'
                                    }`}
                            >
                                <div className={`p-2.5 rounded-xl ${planType === 'TIME_BASED' ? 'bg-indigo-100' : 'bg-gray-100'
                                    }`}>
                                    <Clock className="h-5 w-5" />
                                </div>
                                <span className="font-semibold text-sm">Time Limit</span>
                                <span className="text-xs opacity-70">Hours, days</span>
                            </button>
                            <button
                                type="button"
                                onClick={() => setPlanType('DATA_BASED')}
                                className={`relative flex flex-col items-center gap-2 p-4 rounded-xl border-2 transition-all duration-200 ${planType === 'DATA_BASED'
                                        ? 'border-indigo-500 bg-indigo-50 text-indigo-700 shadow-md shadow-indigo-500/10'
                                        : 'border-gray-200 bg-white text-gray-500 hover:border-gray-300 hover:bg-gray-50'
                                    }`}
                            >
                                <div className={`p-2.5 rounded-xl ${planType === 'DATA_BASED' ? 'bg-indigo-100' : 'bg-gray-100'
                                    }`}>
                                    <HardDrive className="h-5 w-5" />
                                </div>
                                <span className="font-semibold text-sm">Data Limit</span>
                                <span className="text-xs opacity-70">MB, GB</span>
                            </button>
                        </div>
                    </div>

                    {/* ━━━━━━━━━━━━━━ Time Configuration ━━━━━━━━━━━━━━ */}
                    {planType === 'TIME_BASED' && (
                        <div className="space-y-3">
                            {/* Quick presets */}
                            <div>
                                <label className="block text-xs font-medium text-gray-500 mb-2 uppercase tracking-wider">Quick Select</label>
                                <div className="flex flex-wrap gap-2">
                                    {TIME_PRESETS.map((preset) => (
                                        <button
                                            key={preset.minutes}
                                            type="button"
                                            onClick={() => {
                                                setSelectedTimePreset(preset.minutes);
                                                // Update manual inputs to match
                                                if (preset.minutes >= 1440) {
                                                    setTimeValue(Math.round(preset.minutes / 1440));
                                                    setTimeUnit('days');
                                                } else if (preset.minutes >= 60) {
                                                    setTimeValue(Math.round(preset.minutes / 60));
                                                    setTimeUnit('hours');
                                                } else {
                                                    setTimeValue(preset.minutes);
                                                    setTimeUnit('minutes');
                                                }
                                            }}
                                            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${selectedTimePreset === preset.minutes
                                                    ? 'bg-indigo-600 text-white shadow-sm'
                                                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                                                }`}
                                        >
                                            {preset.label}
                                        </button>
                                    ))}
                                </div>
                            </div>

                            {/* Custom time input */}
                            <div>
                                <label className="block text-xs font-medium text-gray-500 mb-1.5 uppercase tracking-wider">Or enter custom</label>
                                <div className="flex gap-2">
                                    <input
                                        type="number"
                                        min="1"
                                        className="flex-1 rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors"
                                        value={timeValue}
                                        onChange={(e) => {
                                            setTimeValue(Number(e.target.value));
                                            setSelectedTimePreset(null);
                                        }}
                                    />
                                    <div className="relative">
                                        <select
                                            className="rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors appearance-none pr-9"
                                            value={timeUnit}
                                            onChange={(e) => {
                                                setTimeUnit(e.target.value as TimeUnit);
                                                setSelectedTimePreset(null);
                                            }}
                                        >
                                            <option value="minutes">Minutes</option>
                                            <option value="hours">Hours</option>
                                            <option value="days">Days</option>
                                        </select>
                                        <ChevronDown className="absolute right-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
                                    </div>
                                </div>
                            </div>

                            {/* Count Type */}
                            <div>
                                <label className="block text-xs font-medium text-gray-500 mb-2 uppercase tracking-wider">Count Type</label>
                                <div className="grid grid-cols-2 gap-2">
                                    <button
                                        type="button"
                                        onClick={() => setCountType('ONLINE_ONLY')}
                                        className={`flex items-center gap-2 p-3 rounded-xl border-2 transition-all text-left ${countType === 'ONLINE_ONLY'
                                                ? 'border-emerald-500 bg-emerald-50 text-emerald-700'
                                                : 'border-gray-200 text-gray-500 hover:border-gray-300'
                                            }`}
                                    >
                                        <Wifi className="h-4 w-4 shrink-0" />
                                        <div>
                                            <div className="font-medium text-sm">Online Time</div>
                                            <div className="text-xs opacity-70">Active use only</div>
                                        </div>
                                    </button>
                                    <button
                                        type="button"
                                        onClick={() => setCountType('WALL_CLOCK')}
                                        className={`flex items-center gap-2 p-3 rounded-xl border-2 transition-all text-left ${countType === 'WALL_CLOCK'
                                                ? 'border-amber-500 bg-amber-50 text-amber-700'
                                                : 'border-gray-200 text-gray-500 hover:border-gray-300'
                                            }`}
                                    >
                                        <Timer className="h-4 w-4 shrink-0" />
                                        <div>
                                            <div className="font-medium text-sm">Wall Clock</div>
                                            <div className="text-xs opacity-70">Starts on activate</div>
                                        </div>
                                    </button>
                                </div>
                            </div>
                        </div>
                    )}

                    {/* ━━━━━━━━━━━━━━ Data Configuration ━━━━━━━━━━━━━━ */}
                    {planType === 'DATA_BASED' && (
                        <div className="space-y-3">
                            {/* Quick presets */}
                            <div>
                                <label className="block text-xs font-medium text-gray-500 mb-2 uppercase tracking-wider">Quick Select</label>
                                <div className="flex flex-wrap gap-2">
                                    {DATA_PRESETS.map((preset) => (
                                        <button
                                            key={preset.label}
                                            type="button"
                                            onClick={() => {
                                                setSelectedDataPreset(preset.bytes);
                                                if (preset.bytes === 0) {
                                                    setDataValue(0);
                                                    setDataUnit('GB');
                                                } else if (preset.bytes >= 1024 * 1024 * 1024) {
                                                    setDataValue(Math.round(preset.bytes / (1024 * 1024 * 1024)));
                                                    setDataUnit('GB');
                                                } else {
                                                    setDataValue(Math.round(preset.bytes / (1024 * 1024)));
                                                    setDataUnit('MB');
                                                }
                                            }}
                                            className={`px-3 py-1.5 rounded-lg text-sm font-medium transition-all ${selectedDataPreset === preset.bytes
                                                    ? 'bg-indigo-600 text-white shadow-sm'
                                                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                                                }`}
                                        >
                                            {preset.label}
                                        </button>
                                    ))}
                                </div>
                            </div>

                            {/* Custom data input */}
                            <div>
                                <label className="block text-xs font-medium text-gray-500 mb-1.5 uppercase tracking-wider">Or enter custom</label>
                                <div className="flex gap-2">
                                    <input
                                        type="number"
                                        min="1"
                                        className="flex-1 rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors"
                                        value={dataValue}
                                        onChange={(e) => {
                                            setDataValue(Number(e.target.value));
                                            setSelectedDataPreset(null);
                                        }}
                                    />
                                    <div className="relative">
                                        <select
                                            className="rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors appearance-none pr-9"
                                            value={dataUnit}
                                            onChange={(e) => {
                                                setDataUnit(e.target.value as DataUnit);
                                                setSelectedDataPreset(null);
                                            }}
                                        >
                                            <option value="MB">MB</option>
                                            <option value="GB">GB</option>
                                        </select>
                                        <ChevronDown className="absolute right-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}

                    {/* ━━━━━━━━━━━━━━ Quantity & Price ━━━━━━━━━━━━━━ */}
                    <div className="grid grid-cols-2 gap-3">
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">Quantity</label>
                            <input
                                type="number"
                                min="1"
                                max="1000"
                                className="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors"
                                value={quantity}
                                onChange={(e) => setQuantity(Number(e.target.value))}
                                required
                            />
                        </div>
                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">Price ($)</label>
                            <input
                                type="number"
                                min="0"
                                step="0.5"
                                className="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors"
                                value={price}
                                onChange={(e) => setPrice(e.target.value)}
                                required
                            />
                        </div>
                    </div>

                    {/* ━━━━━━━━━━━━━━ Advanced Options ━━━━━━━━━━━━━━ */}
                    <div className="border-t border-gray-100 pt-3">
                        <button
                            type="button"
                            onClick={() => setShowAdvanced(!showAdvanced)}
                            className="flex items-center gap-2 text-sm text-gray-500 hover:text-gray-700 transition-colors w-full"
                        >
                            <ChevronDown className={`h-4 w-4 transition-transform duration-200 ${showAdvanced ? 'rotate-180' : ''}`} />
                            <span>Advanced Options</span>
                        </button>

                        {showAdvanced && (
                            <div className="mt-3 space-y-3">
                                {/* Hotspot Profile */}
                                <div>
                                    <label className="block text-sm font-medium text-gray-700 mb-1.5">Hotspot Profile</label>
                                    {availableProfiles.length > 0 ? (
                                        <div className="relative">
                                            <select
                                                className="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors appearance-none pr-10"
                                                value={mikrotikProfile}
                                                onChange={(e) => setMikrotikProfile(e.target.value)}
                                            >
                                                {availableProfiles.map(p => (
                                                    <option key={p} value={p}>{p}</option>
                                                ))}
                                            </select>
                                            <ChevronDown className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
                                        </div>
                                    ) : (
                                        <input
                                            type="text"
                                            className="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors"
                                            value={mikrotikProfile}
                                            onChange={(e) => setMikrotikProfile(e.target.value)}
                                            placeholder="Enter profile name"
                                        />
                                    )}
                                    <p className="text-xs text-gray-400 mt-1">MikroTik User Profile to use</p>
                                </div>

                                {/* Plan Name */}
                                <div>
                                    <div className="flex items-center justify-between mb-1.5">
                                        <label className="block text-sm font-medium text-gray-700">Plan Name</label>
                                        <label className="text-xs text-gray-400 flex items-center gap-1.5 cursor-pointer">
                                            <input
                                                type="checkbox"
                                                checked={autoName}
                                                onChange={(e) => setAutoName(e.target.checked)}
                                                className="rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                                            />
                                            Auto
                                        </label>
                                    </div>
                                    <input
                                        type="text"
                                        className="w-full rounded-xl border border-gray-200 bg-gray-50 px-4 py-2.5 text-sm focus:border-indigo-500 focus:ring-2 focus:ring-indigo-500/20 focus:bg-white transition-colors disabled:opacity-50"
                                        value={planName}
                                        onChange={(e) => { setPlanName(e.target.value); setAutoName(false); }}
                                        placeholder="e.g. 1 Hour Access"
                                        disabled={autoName}
                                    />
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Summary */}
                    <div className="bg-gray-50 rounded-xl p-3.5 border border-gray-100">
                        <div className="text-xs font-medium text-gray-500 uppercase tracking-wider mb-2">Summary</div>
                        <div className="flex items-center justify-between text-sm">
                            <span className="text-gray-600">
                                {quantity}x <strong className="text-gray-900">{planName || '—'}</strong>
                            </span>
                            <span className="font-semibold text-gray-900">
                                {Number(price) > 0 ? `$${Number(price).toFixed(2)} each` : 'Free'}
                            </span>
                        </div>
                        <div className="text-xs text-gray-400 mt-1">
                            {planType === 'TIME_BASED'
                                ? `${getMinutes()} min · ${countType === 'ONLINE_ONLY' ? 'Online time' : 'Wall clock'}`
                                : getBytes() === 0 ? 'Unlimited data' : `${(getBytes() / (1024 * 1024)).toLocaleString()} MB`
                            }
                        </div>
                    </div>

                    {/* Error/Success Messages */}
                    {error && (
                        <div className="bg-red-50 border border-red-200 rounded-xl px-4 py-3 text-sm text-red-700">
                            {error}
                        </div>
                    )}
                    {success && (
                        <div className="bg-green-50 border border-green-200 rounded-xl px-4 py-3 text-sm text-green-700">
                            {success}
                        </div>
                    )}

                    {/* Actions */}
                    <div className="flex gap-3 pt-1">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-4 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-200 rounded-xl hover:bg-gray-50 transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={loading}
                            className="flex-1 px-4 py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-indigo-600 to-purple-600 rounded-xl hover:from-indigo-700 hover:to-purple-700 transition-all shadow-md shadow-indigo-500/20 disabled:opacity-50 disabled:cursor-not-allowed"
                        >
                            {loading ? (
                                <span className="flex items-center justify-center gap-2">
                                    <svg className="animate-spin h-4 w-4" viewBox="0 0 24 24">
                                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                                    </svg>
                                    Generating...
                                </span>
                            ) : (
                                `Generate ${quantity > 1 ? `${quantity} Vouchers` : 'Voucher'}`
                            )}
                        </button>
                    </div>
                </form>
            </div>
        </div>
    );
}
