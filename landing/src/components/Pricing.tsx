import { useLanguage } from '../i18n/context'
import { motion } from 'framer-motion'
import { Check } from 'lucide-react'
import type { TranslationKey } from '../i18n/en'

interface PlanConfig {
  nameKey: TranslationKey
  priceKey: TranslationKey
  featuresKey: TranslationKey
  ctaKey: TranslationKey
  popular: boolean
}

const PLANS: PlanConfig[] = [
  {
    nameKey: 'pricingBasic',
    priceKey: 'pricingBasicPrice',
    featuresKey: 'pricingBasicFeatures',
    ctaKey: 'pricingGetStarted',
    popular: false,
  },
  {
    nameKey: 'pricingPro',
    priceKey: 'pricingProPrice',
    featuresKey: 'pricingProFeatures',
    ctaKey: 'pricingGetStarted',
    popular: true,
  },
  {
    nameKey: 'pricingEnterprise',
    priceKey: 'pricingEnterprisePrice',
    featuresKey: 'pricingEnterpriseFeatures',
    ctaKey: 'pricingContactUs',
    popular: false,
  },
]

export function Pricing() {
  const { t, tArray } = useLanguage()

  return (
    <section id="pricing" className="py-16 md:py-24 bg-white">
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
            {t('pricingTitle')}
          </h2>
          <p className="mx-auto mt-3 max-w-xl text-base text-slate-600 md:text-lg">
            {t('pricingSubtitle')}
          </p>
        </motion.div>

        {/* Cards */}
        <div className="grid gap-6 lg:grid-cols-3 lg:items-center">
          {PLANS.map(({ nameKey, priceKey, featuresKey, ctaKey, popular }, i) => {
            const features = tArray(featuresKey)
            return (
              <motion.div
                key={nameKey}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: '-50px' }}
                transition={{ duration: 0.4, delay: i * 0.1 }}
                className={`relative rounded-2xl border p-6 md:p-8 ${
                  popular
                    ? 'border-blue-600 bg-white shadow-xl shadow-blue-600/10 lg:scale-105'
                    : 'border-slate-200 bg-white'
                }`}
              >
                {popular && (
                  <div className="absolute -top-3 inset-x-0 mx-auto w-fit rounded-full bg-blue-600 px-3 py-1 text-xs font-semibold text-white">
                    {t('pricingPopular')}
                  </div>
                )}

                <div className="mb-6">
                  <h3 className="text-lg font-semibold text-slate-900">{t(nameKey)}</h3>
                  <div className="mt-2 flex items-baseline gap-1">
                    <span className="text-3xl font-extrabold text-slate-900 md:text-4xl">
                      {t(priceKey)}
                    </span>
                    <span className="text-sm text-slate-500">{t('pricingMonth')}</span>
                  </div>
                </div>

                <ul className="mb-8 space-y-3">
                  {features.map((feature, fi) => (
                    <li key={fi} className="flex items-start gap-2.5">
                      <Check className="mt-0.5 h-4 w-4 shrink-0 text-emerald-500" />
                      <span className="text-sm text-slate-600">{feature}</span>
                    </li>
                  ))}
                </ul>

                <a
                  href="#"
                  className={`flex h-12 w-full items-center justify-center rounded-full text-base font-semibold transition-all ${
                    popular
                      ? 'bg-blue-600 text-white shadow-lg shadow-blue-600/25 hover:bg-blue-700 active:bg-blue-800'
                      : 'border border-slate-200 bg-white text-slate-700 hover:border-slate-300 hover:bg-slate-50 active:bg-slate-100'
                  }`}
                >
                  {t(ctaKey)}
                </a>
              </motion.div>
            )
          })}
        </div>
      </div>
    </section>
  )
}
