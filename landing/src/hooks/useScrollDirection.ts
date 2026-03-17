import { useState, useEffect } from 'react'

export function useScrollPast(threshold: number) {
  const [isPast, setIsPast] = useState(false)

  useEffect(() => {
    const handle = () => setIsPast(window.scrollY > threshold)
    window.addEventListener('scroll', handle, { passive: true })
    handle()
    return () => window.removeEventListener('scroll', handle)
  }, [threshold])

  return isPast
}
