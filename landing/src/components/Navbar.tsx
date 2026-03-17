import { useState } from 'react'
import { Menu, Wifi } from 'lucide-react'
import { useLanguage } from '../i18n/context'
import { useScrollPast } from '../hooks/useScrollDirection'
import { LanguageToggle } from './LanguageToggle'
import { MobileMenu } from './MobileMenu'

const NAV_LINKS = [
  { key: 'navFeatures' as const, href: '#features' },
  { key: 'navPricing' as const, href: '#pricing' },
  { key: 'navFAQ' as const, href: '#faq' },
  { key: 'navContact' as const, href: '#contact' },
]

export function Navbar() {
  const { t } = useLanguage()
  const scrolled = useScrollPast(50)
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <>
      <header
        className={`fixed inset-x-0 top-0 z-40 transition-all duration-300 ${
          scrolled
            ? 'bg-white/90 shadow-sm backdrop-blur-md'
            : 'bg-transparent'
        }`}
      >
        <div className="mx-auto flex h-14 max-w-7xl items-center justify-between px-4 md:h-16 md:px-6 lg:px-8">
          {/* Logo */}
          <a href="#" className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600">
              <Wifi className="h-4 w-4 text-white" />
            </div>
            <span className="text-lg font-bold text-slate-900">Wassal</span>
          </a>

          {/* Desktop nav */}
          <nav className="hidden items-center gap-1 md:flex">
            {NAV_LINKS.map(({ key, href }) => (
              <a
                key={key}
                href={href}
                className="rounded-lg px-3 py-2 text-sm font-medium text-slate-600 transition-colors hover:bg-slate-100 hover:text-slate-900"
              >
                {t(key)}
              </a>
            ))}
          </nav>

          {/* Desktop actions */}
          <div className="hidden items-center gap-3 md:flex">
            <LanguageToggle />
            <a
              href="#pricing"
              className="inline-flex h-9 items-center rounded-full bg-blue-600 px-5 text-sm font-semibold text-white transition-colors hover:bg-blue-700 active:bg-blue-800"
            >
              {t('navGetStarted')}
            </a>
          </div>

          {/* Mobile actions */}
          <div className="flex items-center gap-2 md:hidden">
            <LanguageToggle />
            <button
              onClick={() => setMenuOpen(true)}
              className="flex h-10 w-10 items-center justify-center rounded-lg text-slate-700 hover:bg-slate-100 active:bg-slate-200"
              aria-label="Open menu"
            >
              <Menu className="h-5 w-5" />
            </button>
          </div>
        </div>
      </header>

      <MobileMenu isOpen={menuOpen} onClose={() => setMenuOpen(false)} />
    </>
  )
}
