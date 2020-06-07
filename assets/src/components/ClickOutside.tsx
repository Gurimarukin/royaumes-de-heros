/** @jsx jsx */
import {
  FunctionComponent,
  Children,
  createRef,
  useCallback,
  useEffect,
  cloneElement,
  RefObject,
  ReactElement
} from 'react'

export interface Props {
  readonly onClickOutside: (e: MouseEvent) => void
}

export const ClickOutside: FunctionComponent<Props> = ({ onClickOutside, children }) => {
  const refs = Children.map(children, _ => createRef<Node>())

  const handleClick = useCallback(
    (e: MouseEvent) => {
      const isOutside = (refs as RefObject<Node>[]).every(
        ref => ref.current !== null && !ref.current.contains(e.target as Node)
      )
      if (isOutside) onClickOutside(e)
    },
    [onClickOutside, refs]
  )

  useEffect(() => {
    document.addEventListener('click', handleClick)
    return () => document.removeEventListener('click', handleClick)
  }, [handleClick])

  return (Children.map(children, (elt, idx) =>
    cloneElement(elt as ReactElement, { ref: (refs as RefObject<Node>[])[idx] })
  ) as unknown) as ReactElement
}
