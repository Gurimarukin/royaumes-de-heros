/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useCallback, useRef, useEffect } from 'react'

import { Maybe, pipe } from '../utils/fp'

interface Props {
  readonly lines: [number, string][]
  readonly className?: string
}

export const Chat: FunctionComponent<Props> = ({ lines, className }) => {
  const previousMaxScrollTop = useRef<number>(0)

  const container = useRef<Maybe<HTMLDivElement>>(Maybe.none)
  const setContainer = useCallback(
    (elt: HTMLDivElement | null) => (container.current = Maybe.fromNullable(elt)),
    []
  )

  useEffect(() => {
    pipe(
      container.current,
      Maybe.map(elt => {
        const newMaxScrollTop = elt.scrollHeight - elt.clientHeight
        if (elt.scrollTop === previousMaxScrollTop.current) elt.scrollTo(0, newMaxScrollTop)
        previousMaxScrollTop.current = newMaxScrollTop
      })
    )
  }, [lines])

  const onWheel = useCallback((e: React.WheelEvent) => e.stopPropagation(), [])

  return (
    <div ref={setContainer} onWheel={onWheel} css={styles.container} className={className}>
      {lines.map(([key, line]) => (
        <div key={key} css={styles.line}>
          {line}
        </div>
      ))}
    </div>
  )
}

const styles = {
  container: css({
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    color: 'bisque',
    overflowY: 'auto',
    padding: '0 0.1em'
  }),

  line: css({
    padding: '0.1em',

    '&:last-of-type': {
      paddingBottom: '1.33em'
    }
  })
}
