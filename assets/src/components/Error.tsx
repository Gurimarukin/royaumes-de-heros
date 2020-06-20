/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Link } from './Link'
import { ChannelError } from '../models/ChannelError'
import { pipe, Dict, Maybe } from '../utils/fp'

interface Props {
  readonly error: ChannelError
  readonly messages?: Record<number, string>
  readonly link?: [string, string]
}

export const Error: FunctionComponent<Props> = ({ error, messages = {}, link }) => (
  <div css={styles.container}>
    <h2 css={styles.error}>
      {pipe(
        Dict.lookup(String(error.status), messages),
        Maybe.getOrElse(() => 'Erreur')
      )}
    </h2>
    {link === undefined ? null : (
      <Link to={link[0]} css={styles.link}>
        {link[1]}
      </Link>
    )}
  </div>
)

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    backgroundColor: '#222222',
    paddingTop: '1.4em',
    color: 'bisque',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center'
  }),

  error: css({
    fontSize: '1.5em'
  }),

  link: css({
    fontSize: '1.2em',
    color: 'inherit',
    cursor: 'inherit',
    marginTop: '0.67em',
    padding: '0.1em 0.2em',
    transition: 'all 0.2s',

    '&:hover': {
      backgroundColor: 'rgba(255, 255, 255, 0.2)'
    }
  })
}
