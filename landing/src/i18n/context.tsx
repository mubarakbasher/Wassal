import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react'
import { en, type TranslationKey } from './en'
import { ar } from './ar'

type Locale = 'en' | 'ar'

interface LanguageContextType {
  locale: Locale
  isRTL: boolean
  toggleLanguage: () => void
  t: (key: TranslationKey) => string
  tArray: (key: TranslationKey) => string[]
}

const translations = { en, ar }

const LanguageContext = createContext<LanguageContextType | null>(null)

function getInitialLocale(): Locale {
  const stored = localStorage.getItem('wassal-locale')
  if (stored === 'en' || stored === 'ar') return stored
  const browserLang = navigator.language.toLowerCase()
  return browserLang.startsWith('ar') ? 'ar' : 'en'
}

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [locale, setLocale] = useState<Locale>(getInitialLocale)

  useEffect(() => {
    const html = document.documentElement
    html.setAttribute('lang', locale)
    html.setAttribute('dir', locale === 'ar' ? 'rtl' : 'ltr')
    localStorage.setItem('wassal-locale', locale)
  }, [locale])

  const toggleLanguage = useCallback(() => {
    setLocale(prev => (prev === 'en' ? 'ar' : 'en'))
  }, [])

  const t = useCallback(
    (key: TranslationKey): string => {
      const value = translations[locale][key]
      return typeof value === 'string' ? value : String(value)
    },
    [locale],
  )

  const tArray = useCallback(
    (key: TranslationKey): string[] => {
      const value = translations[locale][key]
      return Array.isArray(value) ? value : [String(value)]
    },
    [locale],
  )

  return (
    <LanguageContext.Provider value={{ locale, isRTL: locale === 'ar', toggleLanguage, t, tArray }}>
      {children}
    </LanguageContext.Provider>
  )
}

export function useLanguage() {
  const ctx = useContext(LanguageContext)
  if (!ctx) throw new Error('useLanguage must be used within LanguageProvider')
  return ctx
}
