import { useLanguage } from '../i18n/context'
import { Wifi } from 'lucide-react'

export function Footer() {
  const { t } = useLanguage()

  const productLinks = [
    { label: t('footerFeatures'), href: '#features' },
    { label: t('footerPricing'), href: '#pricing' },
    { label: t('footerMobileApp'), href: '#' },
  ]

  const companyLinks = [
    { label: t('footerAbout'), href: '#' },
    { label: t('footerBlog'), href: '#' },
    { label: t('footerCareers'), href: '#' },
  ]

  const supportLinks = [
    { label: t('footerHelpCenter'), href: '#' },
    { label: t('footerContactUs'), href: '#contact' },
    { label: t('footerDocumentation'), href: '#' },
  ]

  return (
    <footer className="border-t border-slate-200 bg-slate-50 pb-20 md:pb-0">
      <div className="mx-auto max-w-7xl px-4 py-12 md:px-6 lg:px-8">
        <div className="grid gap-8 md:grid-cols-4 md:gap-12">
          {/* Brand */}
          <div className="md:col-span-1">
            <a href="#" className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-600">
                <Wifi className="h-4 w-4 text-white" />
              </div>
              <span className="text-lg font-bold text-slate-900">Wassal</span>
            </a>
            <p className="mt-3 text-sm text-slate-500">{t('footerTagline')}</p>
          </div>

          {/* Product */}
          <div>
            <h4 className="text-sm font-semibold text-slate-900">{t('footerProduct')}</h4>
            <ul className="mt-3 space-y-2">
              {productLinks.map((link) => (
                <li key={link.label}>
                  <a href={link.href} className="text-sm text-slate-500 transition-colors hover:text-slate-700">
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Company */}
          <div>
            <h4 className="text-sm font-semibold text-slate-900">{t('footerCompany')}</h4>
            <ul className="mt-3 space-y-2">
              {companyLinks.map((link) => (
                <li key={link.label}>
                  <a href={link.href} className="text-sm text-slate-500 transition-colors hover:text-slate-700">
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          {/* Support */}
          <div>
            <h4 className="text-sm font-semibold text-slate-900">{t('footerSupport')}</h4>
            <ul className="mt-3 space-y-2">
              {supportLinks.map((link) => (
                <li key={link.label}>
                  <a href={link.href} className="text-sm text-slate-500 transition-colors hover:text-slate-700">
                    {link.label}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="mt-10 flex flex-col items-center justify-between gap-4 border-t border-slate-200 pt-6 md:flex-row">
          <p className="text-xs text-slate-400">{t('footerCopyright')}</p>
          <div className="flex gap-4">
            <a href="#" className="text-xs text-slate-400 transition-colors hover:text-slate-600">
              {t('footerPrivacy')}
            </a>
            <a href="#" className="text-xs text-slate-400 transition-colors hover:text-slate-600">
              {t('footerTerms')}
            </a>
          </div>
        </div>
      </div>
    </footer>
  )
}
