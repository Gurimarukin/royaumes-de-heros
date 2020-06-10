/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useCallback } from 'react'

interface Props {
  readonly lines: [number, string][]
  readonly className?: string
}

export const Chat: FunctionComponent<Props> = ({ lines, className }) => {
  const onWheel = useCallback((e: React.WheelEvent) => e.stopPropagation(), [])
  return (
    <div onWheel={onWheel} css={styles.container} className={className}>
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
    padding: '0.33em'
  }),

  line: css({})
}
