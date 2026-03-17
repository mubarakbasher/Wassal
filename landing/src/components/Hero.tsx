import { useLanguage } from '../i18n/context'
import { motion } from 'framer-motion'
import { Play, ArrowRight, Wifi, BarChart3, Ticket } from 'lucide-react'

export function Hero() {
  const { t, isRTL } = useLanguage()

  return (
    <section
      id="hero"
      className="relative flex min-h-svh items-center overflow-hidden pt-14 md:pt-16"
    >
      {/* Background gradient */}
      <div className="absolute inset-0 -z-10 bg-gradient-to-br from-blue-50 via-white to-emerald-50" />
      <div className="absolute -top-40 end-0 -z-10 h-[500px] w-[500px] rounded-full bg-blue-100/40 blur-3xl" />
      <div className="absolute -bottom-40 start-0 -z-10 h-[400px] w-[400px] rounded-full bg-emerald-100/40 blur-3xl" />

      <div className="mx-auto w-full max-w-7xl px-4 py-12 md:px-6 lg:px-8">
        <div className="flex flex-col items-center gap-12 lg:flex-row lg:gap-16">
          {/* Text content */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="flex-1 text-center lg:text-start"
          >
            <div className="mb-4 inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-3 py-1 text-xs font-medium text-blue-700 md:text-sm">
              <Wifi className="h-3.5 w-3.5" />
              MikroTik Hotspot Management
            </div>

            <h1 className="text-2xl font-extrabold leading-tight tracking-tight text-slate-900 sm:text-3xl md:text-4xl lg:text-5xl">
              {t('heroTitle')}
            </h1>

            <p className="mx-auto mt-4 max-w-xl text-base leading-relaxed text-slate-600 md:text-lg lg:mx-0">
              {t('heroSubtitle')}
            </p>

            <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:justify-center lg:justify-start">
              <a
                href="#pricing"
                className="inline-flex h-12 items-center justify-center gap-2 rounded-full bg-blue-600 px-6 text-base font-semibold text-white shadow-lg shadow-blue-600/25 transition-all hover:bg-blue-700 hover:shadow-xl hover:shadow-blue-600/30 active:bg-blue-800"
              >
                {t('heroCTA')}
                <ArrowRight className={`h-4 w-4 ${isRTL ? 'rotate-180' : ''}`} />
              </a>
              <a
                href="#"
                className="inline-flex h-12 items-center justify-center gap-2 rounded-full border border-slate-200 bg-white px-6 text-base font-semibold text-slate-700 transition-all hover:border-slate-300 hover:bg-slate-50 active:bg-slate-100"
              >
                <Play className="h-4 w-4 text-blue-600" />
                {t('heroSecondaryCTA')}
              </a>
            </div>
          </motion.div>

          {/* Dashboard mockup */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="hidden flex-1 lg:block"
          >
            <div className="relative mx-auto max-w-lg">
              {/* Main card */}
              <div className="rounded-2xl border border-slate-200 bg-white p-6 shadow-2xl">
                <div className="mb-4 flex items-center justify-between">
                  <h3 className="text-sm font-semibold text-slate-900">Dashboard Overview</h3>
                  <span className="rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-medium text-emerald-700">Live</span>
                </div>
                <div className="grid grid-cols-3 gap-3">
                  <div className="rounded-xl bg-blue-50 p-3 text-center">
                    <Wifi className="mx-auto mb-1 h-5 w-5 text-blue-600" />
                    <div className="text-lg font-bold text-slate-900">12</div>
                    <div className="text-xs text-slate-500">Routers</div>
                  </div>
                  <div className="rounded-xl bg-emerald-50 p-3 text-center">
                    <BarChart3 className="mx-auto mb-1 h-5 w-5 text-emerald-600" />
                    <div className="text-lg font-bold text-slate-900">$2.4k</div>
                    <div className="text-xs text-slate-500">Revenue</div>
                  </div>
                  <div className="rounded-xl bg-purple-50 p-3 text-center">
                    <Ticket className="mx-auto mb-1 h-5 w-5 text-purple-600" />
                    <div className="text-lg font-bold text-slate-900">847</div>
                    <div className="text-xs text-slate-500">Vouchers</div>
                  </div>
                </div>
                {/* Fake chart bars */}
                <div className="mt-4 flex items-end gap-1.5 h-20">
                  {[40, 65, 45, 80, 55, 70, 90, 60, 75, 85, 50, 95].map((h, i) => (
                    <div
                      key={i}
                      className="flex-1 rounded-t bg-blue-200"
                      style={{ height: `${h}%` }}
                    />
                  ))}
                </div>
              </div>

              {/* Floating notification */}
              <div className="absolute -top-4 -end-4 rounded-xl border border-slate-100 bg-white p-3 shadow-lg">
                <div className="flex items-center gap-2">
                  <div className="h-2 w-2 rounded-full bg-emerald-500" />
                  <span className="text-xs font-medium text-slate-700">Router Online</span>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}
