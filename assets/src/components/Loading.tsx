/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

export const Loading: FunctionComponent = () => <div css={styles.container}>Chargement...</div>

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    // backgroundImage: "url('/images/bg.jpg')",
    // backgroundSize: '100% 100%',
    backgroundColor: '#222222',
    fontSize: '2em',
    color: 'bisque',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  })
}
