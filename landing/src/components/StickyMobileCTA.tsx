import { useLanguage } from '../i18n/context'
import { useScrollPast } from '../hooks/useScrollDirection'
import { motion, AnimatePresence } from 'framer-motion'

export function StickyMobileCTA() {
  const { t } = useLanguage()
  const showCTA = useScrollPast(600)

  return (
    <AnimatePresence>
      {showCTA && (
        <motion.div
          initial={{ y: '100%' }}
          animate={{ y: 0 }}
          exit={{ y: '100%' }}
          transition={{ type: 'spring', damping: 25, stiffness: 300 }}
          className="fixed inset-x-0 bottom-0 z-40 border-t border-slate-200 bg-white/90 px-4 py-3 backdrop-blur-md md:hidden"
        >
          <a
            href="#pricing"
            className="flex h-12 w-full items-center justify-center rounded-full bg-blue-600 text-base font-semibold text-white shadow-lg shadow-blue-600/25 transition-colors hover:bg-blue-700 active:bg-blue-800"
          >
            {t('navGetStarted')}
          </a>
        </motion.div>
      )}
    </AnimatePresence>
  )
}
