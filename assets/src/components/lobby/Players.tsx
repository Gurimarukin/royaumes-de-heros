/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useContext } from 'react'

import { Check, Crown, Ban } from '../icons'
import { UserContext } from '../../contexts/UserContext'
import { PlayerId } from '../../models/PlayerId'
import { Lobby } from '../../models/lobby/Lobby'
import { pipe } from '../../utils/fp'

interface Props {
  readonly lobby: Lobby
}

const SELF = 'self'

export const Players: FunctionComponent<Props> = ({ lobby }) => {
  const { user } = useContext(UserContext)

  const isOwner = user.id === lobby.owner

  return (
    <table css={styles.container}>
      <thead>
        <tr css={styles.header}>
          <th css={styles.owner} />
          <th css={styles.playerName}>Joueurs</th>
          <th css={styles.ready}>Prêt</th>
          {isOwner ? <td css={styles.ownerActions} /> : null}
        </tr>
      </thead>
      <tbody>
        {lobby.players.map(([id, player]) =>
          pipe(id === user.id, isSelf => (
            <tr key={PlayerId.unwrap(id)} css={styles.player} className={isSelf ? SELF : undefined}>
              <td css={styles.owner}>
                {id === lobby.owner ? (
                  <span title='Propriétaire'>
                    <Crown />
                  </span>
                ) : null}
              </td>
              <td css={styles.playerName}>{player.name}</td>
              <td css={styles.ready}>
                <Check />
              </td>
              {isOwner ? (
                <td css={styles.ownerActions}>
                  {!isSelf ? (
                    <span title='Expulser' css={styles.ban}>
                      <Ban />
                    </span>
                  ) : null}
                </td>
              ) : null}
            </tr>
          ))
        )}
      </tbody>
    </table>
  )
}

const styles = {
  container: css({
    width: '100%',
    maxWidth: '1100px',
    fontSize: '1.1em',
    display: 'flex',
    flexDirection: 'column',

    '& td, & th': {
      padding: '0.67em 0.33em'
    }
  }),

  header: css({
    width: '100%',
    display: 'flex',
    borderBottom: '3px double darkgoldenrod',
    fontWeight: 'bold'
  }),

  player: css({
    display: 'flex',

    '&:nth-of-type(2n)': {
      backgroundColor: 'rgba(245, 222, 179, 0.3)'
    }
  }),

  owner: css({
    width: '12ch',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  }),

  playerName: css({
    flex: '1 0 0',
    textAlign: 'left',

    [`tr.${SELF} &`]: {
      textDecoration: 'underline'
    }
  }),

  ready: css({
    width: '5ch',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  }),

  ownerActions: css({
    width: '12ch',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  }),

  ban: css({
    color: '#ca0404',
    display: 'flex'
  })
}
