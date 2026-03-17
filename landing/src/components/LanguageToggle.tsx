import { useLanguage } from '../i18n/context'
import { Languages } from 'lucide-react'

export function LanguageToggle({ className = '' }: { className?: string }) {
  const { locale, toggleLanguage } = useLanguage()

  return (
    <button
      onClick={toggleLanguage}
      className={`inline-flex items-center gap-1.5 rounded-full border border-slate-200 px-3 py-1.5 text-sm font-medium text-slate-700 transition-colors hover:bg-slate-100 active:bg-slate-200 ${className}`}
      aria-label={locale === 'en' ? 'Switch to Arabic' : 'التبديل إلى الإنجليزية'}
    >
      <Languages className="h-4 w-4" />
      <span>{locale === 'en' ? 'العربية' : 'English'}</span>
    </button>
  )
}
