/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

export const Loading: FunctionComponent = () => <div css={styles.container}>Chargement...</div>

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    backgroundColor: '#222222',
    fontSize: '2em',
    color: 'bisque',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  })
}
