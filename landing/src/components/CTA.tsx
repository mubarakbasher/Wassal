import { useLanguage } from '../i18n/context'
import { motion } from 'framer-motion'
import { ArrowRight } from 'lucide-react'

export function CTA() {
  const { t, isRTL } = useLanguage()

  return (
    <section id="contact" className="py-16 md:py-24">
      <div className="mx-auto max-w-7xl px-4 md:px-6 lg:px-8">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.5 }}
          className="relative overflow-hidden rounded-2xl bg-gradient-to-br from-blue-600 to-blue-800 px-6 py-12 text-center md:px-12 md:py-16 lg:py-20"
        >
          {/* Decorative blobs */}
          <div className="absolute -top-20 -end-20 h-60 w-60 rounded-full bg-white/10 blur-3xl" />
          <div className="absolute -bottom-20 -start-20 h-60 w-60 rounded-full bg-white/10 blur-3xl" />

          <div className="relative">
            <h2 className="text-xl font-extrabold text-white sm:text-2xl md:text-3xl lg:text-4xl">
              {t('ctaTitle')}
            </h2>
            <p className="mx-auto mt-3 max-w-xl text-sm text-blue-100 md:text-base lg:text-lg">
              {t('ctaSubtitle')}
            </p>
            <div className="mt-8 flex flex-col items-center gap-3 sm:flex-row sm:justify-center">
              <a
                href="#pricing"
                className="inline-flex h-12 w-full items-center justify-center gap-2 rounded-full bg-white px-6 text-base font-semibold text-blue-700 shadow-lg transition-all hover:bg-blue-50 active:bg-blue-100 sm:w-auto"
              >
                {t('ctaCTA')}
                <ArrowRight className={`h-4 w-4 ${isRTL ? 'rotate-180' : ''}`} />
              </a>
            </div>
            <p className="mt-3 text-xs text-blue-200 md:text-sm">{t('ctaNoCreditCard')}</p>
          </div>
        </motion.div>
      </div>
    </section>
  )
}
