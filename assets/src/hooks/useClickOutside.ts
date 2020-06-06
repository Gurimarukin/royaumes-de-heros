import { RefObject, Dispatch, createRef, useEffect, useCallback } from 'react'

export const useClickOutside = <A extends Node>(onClickOutside: Dispatch<void>): RefObject<A> => {
  const ref = createRef<A>()

  const handleClick = useCallback(
    (e: MouseEvent) => {
      const isOutside = ref.current === null || !ref.current.contains(e.target as A)
      if (isOutside) onClickOutside()
    },
    [onClickOutside, ref]
  )

  useEffect(() => {
    document.body.addEventListener('click', handleClick)
    return () => document.body.removeEventListener('click', handleClick)
  }, [handleClick])

  return ref
}
