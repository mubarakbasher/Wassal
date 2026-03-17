import { X } from 'lucide-react'
import { useLanguage } from '../i18n/context'
import { LanguageToggle } from './LanguageToggle'
import { motion, AnimatePresence } from 'framer-motion'

interface MobileMenuProps {
  isOpen: boolean
  onClose: () => void
}

const NAV_LINKS = [
  { key: 'navFeatures' as const, href: '#features' },
  { key: 'navPricing' as const, href: '#pricing' },
  { key: 'navFAQ' as const, href: '#faq' },
  { key: 'navContact' as const, href: '#contact' },
]

export function MobileMenu({ isOpen, onClose }: MobileMenuProps) {
  const { t } = useLanguage()

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 0.2 }}
          className="fixed inset-0 z-50 bg-black/50 md:hidden"
          onClick={onClose}
        >
          <motion.div
            initial={{ x: '100%' }}
            animate={{ x: 0 }}
            exit={{ x: '100%' }}
            transition={{ type: 'spring', damping: 25, stiffness: 300 }}
            className="absolute inset-y-0 end-0 w-4/5 max-w-sm bg-white shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex h-full flex-col">
              <div className="flex items-center justify-between px-6 py-4">
                <span className="text-lg font-bold text-blue-600">Wassal</span>
                <button
                  onClick={onClose}
                  className="flex h-10 w-10 items-center justify-center rounded-full text-slate-500 hover:bg-slate-100 active:bg-slate-200"
                  aria-label="Close menu"
                >
                  <X className="h-5 w-5" />
                </button>
              </div>

              <nav className="flex-1 px-6 py-4">
                <ul className="space-y-1">
                  {NAV_LINKS.map(({ key, href }) => (
                    <li key={key}>
                      <a
                        href={href}
                        onClick={onClose}
                        className="flex h-12 items-center rounded-lg px-4 text-base font-medium text-slate-700 transition-colors hover:bg-slate-50 active:bg-slate-100"
                      >
                        {t(key)}
                      </a>
                    </li>
                  ))}
                </ul>
              </nav>

              <div className="border-t border-slate-100 px-6 py-6 space-y-4">
                <LanguageToggle className="w-full justify-center" />
                <a
                  href="#pricing"
                  onClick={onClose}
                  className="flex h-12 items-center justify-center rounded-full bg-blue-600 text-base font-semibold text-white transition-colors hover:bg-blue-700 active:bg-blue-800"
                >
                  {t('navGetStarted')}
                </a>
              </div>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
