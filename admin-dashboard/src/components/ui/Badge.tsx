import { clsx } from "clsx";
import { twMerge } from "tailwind-merge";

interface BadgeProps {
    children: React.ReactNode;
    variant?: 'success' | 'warning' | 'error' | 'default' | 'info';
    className?: string;
}

export function Badge({ children, variant = 'default', className }: BadgeProps) {
    const variants = {
        default: "bg-gray-100 text-gray-800",
        success: "bg-green-100 text-green-800",
        warning: "bg-yellow-100 text-yellow-800",
        error: "bg-red-100 text-red-800",
        info: "bg-blue-100 text-blue-800",
    };

    return (
        <span className={twMerge(clsx(
            "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium",
            variants[variant],
            className
        ))}>
            {children}
        </span>
    );
}
