/** @jsx jsx */
import * as t from 'io-ts'
import { jsx } from '@emotion/core'
import { useContext, FunctionComponent, useState } from 'react'

import { Link } from './Link'
import { Router } from './Router'
import { HistoryContext } from '../contexts/HistoryContext'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { SquadShort } from '../models/SquadShort'
import { pipe, Future } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'

export const Squads: FunctionComponent = () => {
  const history = useContext(HistoryContext)
  const user = useContext(UserContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadShort[]>>(AsyncState.Loading)

  const [, channel] = useChannel(user.token, 'squads', setState, t.array(SquadShort.codec).decode)

  return (
    <div>
      <div>{user.name}</div>
      {pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))}
    </div>
  )

  function onLoading() {
    return <div>Loading...</div>
  }

  function onError(error: ChannelError) {
    return <pre>Error: {JSON.stringify(error)}</pre>
  }

  function onSuccess(squads: SquadShort[]) {
    return (
      <div>
        <button onClick={createGame()}>Nouvelle partie</button>

        <table>
          <thead>
            <tr>
              <th>Phase</th>
              <th>Joueurs</th>
              <th />
            </tr>
          </thead>
          <tbody>
            {squads.map(squad => (
              <tr key={squad.id}>
                <td>{squad.stage}</td>
                <td>{squad.n_players}</td>
                <td>
                  {squad.stage === 'lobby' ? (
                    <Link to={Router.routes.squad(squad.id)}>rejoindre</Link>
                  ) : null}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    )
  }

  function createGame(): () => void {
    return () => {
      pipe(
        channel.push('create', {}),
        PhoenixUtils.toFuture,
        Future.map(({ id }) => history.push(Router.routes.squad(id))),
        Future.runUnsafe
      )
    }
  }
}
