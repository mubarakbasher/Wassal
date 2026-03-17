import { useState } from 'react'
import { useLanguage } from '../i18n/context'
import { motion, AnimatePresence } from 'framer-motion'
import { Quote, ChevronLeft, ChevronRight } from 'lucide-react'
import type { TranslationKey } from '../i18n/en'

interface TestimonialData {
  quoteKey: TranslationKey
  nameKey: TranslationKey
  roleKey: TranslationKey
  initials: string
}

const TESTIMONIALS: TestimonialData[] = [
  { quoteKey: 'testimonial1Quote', nameKey: 'testimonial1Name', roleKey: 'testimonial1Role', initials: 'AR' },
  { quoteKey: 'testimonial2Quote', nameKey: 'testimonial2Name', roleKey: 'testimonial2Role', initials: 'SM' },
  { quoteKey: 'testimonial3Quote', nameKey: 'testimonial3Name', roleKey: 'testimonial3Role', initials: 'OH' },
]

export function Testimonials() {
  const { t, isRTL } = useLanguage()
  const [current, setCurrent] = useState(0)

  const next = () => setCurrent((prev) => (prev + 1) % TESTIMONIALS.length)
  const prev = () => setCurrent((prev) => (prev - 1 + TESTIMONIALS.length) % TESTIMONIALS.length)

  return (
    <section className="bg-slate-50 py-16 md:py-24">
      <div className="mx-auto max-w-7xl px-4 md:px-6 lg:px-8">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true, margin: '-100px' }}
          transition={{ duration: 0.5 }}
          className="text-center mb-12 md:mb-16"
        >
          <h2 className="text-2xl font-extrabold text-slate-900 sm:text-3xl lg:text-4xl">
            {t('testimonialsTitle')}
          </h2>
          <p className="mx-auto mt-3 max-w-xl text-base text-slate-600 md:text-lg">
            {t('testimonialsSubtitle')}
          </p>
        </motion.div>

        {/* Desktop grid */}
        <div className="hidden lg:grid lg:grid-cols-3 lg:gap-6">
          {TESTIMONIALS.map(({ quoteKey, nameKey, roleKey, initials }, i) => (
            <motion.div
              key={quoteKey}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-50px' }}
              transition={{ duration: 0.4, delay: i * 0.1 }}
              className="rounded-2xl border border-slate-200 bg-white p-6"
            >
              <Quote className="mb-4 h-8 w-8 text-blue-200" />
              <p className="text-base leading-relaxed text-slate-600">{t(quoteKey)}</p>
              <div className="mt-6 flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 text-sm font-bold text-blue-600">
                  {initials}
                </div>
                <div>
                  <div className="text-sm font-semibold text-slate-900">{t(nameKey)}</div>
                  <div className="text-xs text-slate-500">{t(roleKey)}</div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {/* Mobile carousel */}
        <div className="lg:hidden">
          <div className="relative overflow-hidden">
            <AnimatePresence mode="wait">
              <motion.div
                key={current}
                initial={{ opacity: 0, x: isRTL ? -30 : 30 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: isRTL ? 30 : -30 }}
                transition={{ duration: 0.3 }}
                className="rounded-2xl border border-slate-200 bg-white p-6"
              >
                <Quote className="mb-4 h-6 w-6 text-blue-200" />
                <p className="text-base leading-relaxed text-slate-600">
                  {t(TESTIMONIALS[current].quoteKey)}
                </p>
                <div className="mt-6 flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 text-sm font-bold text-blue-600">
                    {TESTIMONIALS[current].initials}
                  </div>
                  <div>
                    <div className="text-sm font-semibold text-slate-900">
                      {t(TESTIMONIALS[current].nameKey)}
                    </div>
                    <div className="text-xs text-slate-500">
                      {t(TESTIMONIALS[current].roleKey)}
                    </div>
                  </div>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>

          {/* Navigation */}
          <div className="mt-6 flex items-center justify-center gap-4">
            <button
              onClick={prev}
              className="flex h-10 w-10 items-center justify-center rounded-full border border-slate-200 text-slate-600 transition-colors hover:bg-slate-100 active:bg-slate-200"
              aria-label="Previous testimonial"
            >
              <ChevronLeft className="h-5 w-5" />
            </button>

            {/* Dot indicators */}
            <div className="flex gap-2">
              {TESTIMONIALS.map((_, i) => (
                <button
                  key={i}
                  onClick={() => setCurrent(i)}
                  className={`h-2.5 rounded-full transition-all ${
                    i === current ? 'w-6 bg-blue-600' : 'w-2.5 bg-slate-300'
                  }`}
                  aria-label={`Go to testimonial ${i + 1}`}
                />
              ))}
            </div>

            <button
              onClick={next}
              className="flex h-10 w-10 items-center justify-center rounded-full border border-slate-200 text-slate-600 transition-colors hover:bg-slate-100 active:bg-slate-200"
              aria-label="Next testimonial"
            >
              <ChevronRight className="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </section>
  )
}
