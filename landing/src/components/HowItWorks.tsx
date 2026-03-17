import { useLanguage } from '../i18n/context'
import { motion } from 'framer-motion'
import { UserPlus, Router, Banknote } from 'lucide-react'
import type { TranslationKey } from '../i18n/en'

const STEPS: { icon: typeof UserPlus; titleKey: TranslationKey; descKey: TranslationKey; num: number }[] = [
  { icon: UserPlus, titleKey: 'howStep1Title', descKey: 'howStep1Desc', num: 1 },
  { icon: Router, titleKey: 'howStep2Title', descKey: 'howStep2Desc', num: 2 },
  { icon: Banknote, titleKey: 'howStep3Title', descKey: 'howStep3Desc', num: 3 },
]

export function HowItWorks() {
  const { t } = useLanguage()

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
            {t('howTitle')}
          </h2>
          <p className="mx-auto mt-3 max-w-xl text-base text-slate-600 md:text-lg">
            {t('howSubtitle')}
          </p>
        </motion.div>

        {/* Steps: vertical on mobile, horizontal on md+ */}
        <div className="relative">
          {/* Horizontal connector line (desktop) */}
          <div className="absolute top-12 hidden h-0.5 bg-blue-200 md:block" style={{ left: '16.666%', right: '16.666%' }} />

          <div className="flex flex-col gap-8 md:flex-row md:gap-6">
            {STEPS.map(({ icon: Icon, titleKey, descKey, num }, i) => (
              <motion.div
                key={num}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: '-50px' }}
                transition={{ duration: 0.4, delay: i * 0.15 }}
                className="relative flex gap-4 md:flex-1 md:flex-col md:items-center md:text-center"
              >
                {/* Vertical connector line (mobile only) */}
                {i < STEPS.length - 1 && (
                  <div className="absolute start-5 top-12 h-[calc(100%+2rem)] w-0.5 bg-blue-200 md:hidden" />
                )}

                {/* Number circle */}
                <div className="relative z-10 flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-blue-600 text-sm font-bold text-white shadow-lg shadow-blue-600/25 md:h-12 md:w-12 md:text-base">
                  {num}
                </div>

                <div>
                  <div className="mb-2 flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50 md:mx-auto md:mb-3 md:h-12 md:w-12">
                    <Icon className="h-5 w-5 text-blue-600 md:h-6 md:w-6" />
                  </div>
                  <h3 className="text-base font-semibold text-slate-900 md:text-lg">
                    {t(titleKey)}
                  </h3>
                  <p className="mt-1 text-sm text-slate-500 md:mt-2 md:text-base">
                    {t(descKey)}
                  </p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
