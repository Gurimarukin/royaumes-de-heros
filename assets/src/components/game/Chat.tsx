/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useCallback } from 'react'

interface Props {
  readonly lines: [number, string][]
}

export const Chat: FunctionComponent<Props> = ({ lines }) => {
  const onWheel = useCallback((e: React.WheelEvent) => e.stopPropagation(), [])
  return (
    <div onWheel={onWheel} css={styles.container}>
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
    position: 'absolute',
    right: 0,
    top: 0,
    height: '40vh',
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    color: 'bisque',
    overflowY: 'auto',
    padding: '0.33em',
    width: '200px'
  }),

  line: css({})
}
