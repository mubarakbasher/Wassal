import { useLanguage } from '../i18n/context'
import { motion } from 'framer-motion'
import { Wifi, Ticket, Activity, Users, BarChart3, Smartphone } from 'lucide-react'
import type { TranslationKey } from '../i18n/en'

const FEATURES: { icon: typeof Wifi; titleKey: TranslationKey; descKey: TranslationKey; color: string; bg: string }[] = [
  { icon: Wifi, titleKey: 'featureRouter', descKey: 'featureRouterDesc', color: 'text-blue-600', bg: 'bg-blue-50' },
  { icon: Ticket, titleKey: 'featureVoucher', descKey: 'featureVoucherDesc', color: 'text-emerald-600', bg: 'bg-emerald-50' },
  { icon: Activity, titleKey: 'featureMonitoring', descKey: 'featureMonitoringDesc', color: 'text-purple-600', bg: 'bg-purple-50' },
  { icon: Users, titleKey: 'featureRoles', descKey: 'featureRolesDesc', color: 'text-orange-600', bg: 'bg-orange-50' },
  { icon: BarChart3, titleKey: 'featureSales', descKey: 'featureSalesDesc', color: 'text-rose-600', bg: 'bg-rose-50' },
  { icon: Smartphone, titleKey: 'featureMobile', descKey: 'featureMobileDesc', color: 'text-cyan-600', bg: 'bg-cyan-50' },
]

export function Features() {
  const { t } = useLanguage()

  return (
    <section id="features" className="py-16 md:py-24 bg-white">
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
            {t('featuresTitle')}
          </h2>
          <p className="mx-auto mt-3 max-w-2xl text-base text-slate-600 md:text-lg">
            {t('featuresSubtitle')}
          </p>
        </motion.div>

        {/* Cards grid: 1-col mobile, 2-col sm, 3-col lg */}
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 md:gap-6">
          {FEATURES.map(({ icon: Icon, titleKey, descKey, color, bg }, i) => (
            <motion.div
              key={titleKey}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-50px' }}
              transition={{ duration: 0.4, delay: i * 0.08 }}
              className="group flex gap-4 rounded-xl border border-slate-100 p-4 transition-all hover:border-slate-200 hover:shadow-lg sm:flex-col sm:gap-0 sm:p-6"
            >
              <div className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-xl ${bg} sm:mb-4 sm:h-12 sm:w-12`}>
                <Icon className={`h-5 w-5 ${color} sm:h-6 sm:w-6`} />
              </div>
              <div>
                <h3 className="text-base font-semibold text-slate-900 sm:text-lg">
                  {t(titleKey)}
                </h3>
                <p className="mt-1 text-sm leading-relaxed text-slate-500 sm:mt-2 sm:text-base">
                  {t(descKey)}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}
