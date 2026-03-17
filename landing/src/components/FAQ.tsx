import { useState } from 'react'
import { useLanguage } from '../i18n/context'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronDown } from 'lucide-react'
import type { TranslationKey } from '../i18n/en'

const FAQ_ITEMS: { qKey: TranslationKey; aKey: TranslationKey }[] = [
  { qKey: 'faq1Q', aKey: 'faq1A' },
  { qKey: 'faq2Q', aKey: 'faq2A' },
  { qKey: 'faq3Q', aKey: 'faq3A' },
  { qKey: 'faq4Q', aKey: 'faq4A' },
  { qKey: 'faq5Q', aKey: 'faq5A' },
  { qKey: 'faq6Q', aKey: 'faq6A' },
  { qKey: 'faq7Q', aKey: 'faq7A' },
]

export function FAQ() {
  const { t } = useLanguage()
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  const toggle = (i: number) => setOpenIndex(prev => (prev === i ? null : i))

  return (
    <section id="faq" className="py-16 md:py-24 bg-white">
      <div className="mx-auto max-w-3xl px-4 md:px-6 lg:px-8">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.5 }}
          className="text-center mb-12 md:mb-16"
        >
          <h2 className="text-2xl font-extrabold text-slate-900 sm:text-3xl lg:text-4xl">
            {t('faqTitle')}
          </h2>
          <p className="mx-auto mt-3 max-w-xl text-base text-slate-600 md:text-lg">
            {t('faqSubtitle')}
          </p>
        </motion.div>

        {/* Accordion */}
        <div className="divide-y divide-slate-200 rounded-2xl border border-slate-200">
          {FAQ_ITEMS.map(({ qKey, aKey }, i) => {
            const isOpen = openIndex === i
            return (
              <div key={qKey}>
                <button
                  onClick={() => toggle(i)}
                  className="flex w-full items-center justify-between gap-4 px-5 py-4 text-start transition-colors hover:bg-slate-50 active:bg-slate-100 md:px-6 md:py-5"
                  style={{ minHeight: '48px' }}
                  aria-expanded={isOpen}
                >
                  <span className="text-sm font-semibold text-slate-900 md:text-base">
                    {t(qKey)}
                  </span>
                  <ChevronDown
                    className={`h-5 w-5 shrink-0 text-slate-400 transition-transform duration-200 ${
                      isOpen ? 'rotate-180' : ''
                    }`}
                  />
                </button>

                <AnimatePresence initial={false}>
                  {isOpen && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.2 }}
                      className="overflow-hidden"
                    >
                      <div className="px-5 pb-4 text-sm leading-relaxed text-slate-600 md:px-6 md:pb-5 md:text-base">
                        {t(aKey)}
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
