/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { ReactNode, forwardRef } from 'react'

export interface DialogProps {
  readonly shown: boolean
  readonly title?: ReactNode
  readonly children?: ReactNode
}

export const Dialog = forwardRef<HTMLDivElement, DialogProps>(({ shown, title, children }, ref) => (
  <div ref={ref} css={styles.container}>
    <div css={styles.box} className={shown ? 'shown' : undefined}>
      <h2 css={styles.title}>{title}</h2>
      <div>{children}</div>
    </div>
  </div>
))

const styles = {
  container: css({
    position: 'absolute',
    left: 0,
    top: 0,
    width: '100%',
    height: 0,
    display: 'flex',
    justifyContent: 'center'
  }),

  box: css({
    position: 'absolute',
    backgroundColor: 'rgba(0, 0, 0, 0.9)',
    border: '3px double goldenrod',
    color: 'white',
    borderTop: 0,
    height: 'auto',
    maxHeight: '67vh',
    marginTop: '-67vh',

    '&.shown': {
      marginTop: 0
    }
  }),

  title: css({
    fontSize: '1.67em',
    textAlign: 'center',
    padding: '0.67em 1.33em'
  })
}
