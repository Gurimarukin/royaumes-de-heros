/** @jsx jsx */
import * as D from 'io-ts/lib/Decoder'
import { jsx, css } from '@emotion/core'
import { Channel } from 'phoenix'
import { useContext, FunctionComponent, useState, useCallback } from 'react'

import { ButtonUnderline } from './Buttons'
import { Link } from './Link'
import { Loading } from './Loading'
import { Router } from './Router'
import { HistoryContext } from '../contexts/HistoryContext'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { Stage } from '../models/Stage'
import { SquadId } from '../models/SquadId'
import { SquadShort } from '../models/SquadShort'
import { pipe, Future, flow, Either } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'

export const Squads: FunctionComponent = () => {
  const user = useContext(UserContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadShort[]>>(AsyncState.Loading)

  const onJoinSuccess = useCallback(
    PhoenixUtils.handleResponse(PhoenixUtils.decodeBody(D.array(SquadShort.codec).decode))(
      flow(AsyncState.Success, setState)
    ),
    []
  )

  const [, channel] = useChannel(user.token, 'squads', { onJoinSuccess, onUpdate: onJoinSuccess })

  return pipe(state, AsyncState.fold({ onLoading, onError, onSuccess: onSuccess(channel) }))

  function onLoading(): JSX.Element {
    return <Loading />
  }

  function onError(error: ChannelError): JSX.Element {
    return <pre>Error: {JSON.stringify(error)}</pre>
  }

  function onSuccess(channel: Channel): (squads: SquadShort[]) => JSX.Element {
    return squads => <SuccesSquads channel={channel} squads={squads} />
  }
}

const idCodec = D.type({
  id: SquadId.codec as D.Decoder<SquadId>
})

interface Props {
  readonly channel: Channel
  readonly squads: SquadShort[]
}

const SuccesSquads: FunctionComponent<Props> = ({ channel, squads }) => {
  const history = useContext(HistoryContext)
  const user = useContext(UserContext)

  const createGame = useCallback(() => {
    pipe(
      () => channel.push('create', {}),
      PhoenixUtils.pushToFuture,
      Future.map(
        Either.fold(
          _ => {},
          flow(
            idCodec.decode,
            Either.map(({ id }) => history.push(Router.routes.squad(id)))
          )
        )
      ),
      Future.runUnsafe
    )
  }, [channel, history])

  return (
    <div css={styles.container}>
      <div css={styles.header}>
        <h1>Royaumes de Héros</h1>
        <div css={styles.pseudo}>Pseudalité : {user.name}</div>
        <ButtonUnderline onClick={createGame}>Nouvelle partie</ButtonUnderline>
      </div>

      <div css={styles.squadsContainer}>
        {squads.length === 0 ? (
          <div css={styles.squads}>Pas de partie en cours.</div>
        ) : (
          <table css={styles.squads}>
            <thead>
              <tr css={styles.squadsHeader}>
                <th>Phase</th>
                <th>Joueurs</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {squads.map(squad => (
                <tr key={SquadId.unwrap(squad.id)} css={styles.squad}>
                  <td>{stageLabel(squad.stage)}</td>
                  <td css={styles.squadNPlayers}>{squad.n_players}</td>
                  <td css={styles.squadJoinContainer}>
                    {squad.stage === 'lobby' ? (
                      <Link to={Router.routes.squad(squad.id)} css={styles.squadJoin}>
                        rejoindre
                      </Link>
                    ) : null}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}

function stageLabel(stage: Stage): string {
  switch (stage) {
    case 'lobby':
      return 'Salon'
    case 'game':
      return 'En partie'
  }
}

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    backgroundImage: "url('/images/bg.jpg')",
    backgroundSize: '100% 100%',
    overflowY: 'auto',
    color: 'bisque'
  }),

  header: css({
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    backgroundColor: '#6a0080',
    padding: '2em 0 1em'
    // boxShadow: '0 0 8px wheat'
  }),

  pseudo: css({
    fontSize: '1.2em',
    margin: '2em 0'
  }),

  squadsContainer: css({
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    paddingTop: '2em'
  }),

  squads: css({
    width: '1100px',
    fontSize: '1.1em',

    '& td, & th': {
      padding: '0.67em 0.33em'
    }
  }),

  squadsHeader: css({
    borderBottom: '3px double darkgoldenrod'
  }),

  squad: css({
    '&:nth-of-type(2n)': {
      backgroundColor: 'rgba(245, 222, 179, 0.3)'
    }
  }),

  squadNPlayers: css({
    textAlign: 'center'
  }),

  squadJoinContainer: css({
    textAlign: 'right'
  }),

  squadJoin: css({
    color: 'inherit',
    cursor: 'inherit',

    '&:not(:hover)': {
      textDecoration: 'none'
    }
  })
}
