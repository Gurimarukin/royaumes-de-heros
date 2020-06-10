import { useEffect } from 'react'

export function useWindowEvent<K extends keyof WindowEventMap>(
  event: K,
  listener: (e: WindowEventMap[K]) => void
): void {
  useEffect(() => {
    window.addEventListener(event, listener)
    return () => window.removeEventListener(event, listener)
  }, [event, listener])
}
