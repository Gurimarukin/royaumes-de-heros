/** @jsx jsx */
import * as D from 'io-ts/lib/Decoder'
import { jsx } from '@emotion/core'
import { useContext, FunctionComponent, useState, useCallback } from 'react'

import { Link } from './Link'
import { Router } from './Router'
import { HistoryContext } from '../contexts/HistoryContext'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { SquadShort } from '../models/SquadShort'
import { pipe, Future, flow, Either } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'
import { SquadId } from '../models/SquadId'

export const Squads: FunctionComponent = () => {
  const history = useContext(HistoryContext)
  const user = useContext(UserContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadShort[]>>(AsyncState.Loading)

  const onJoinSuccess = useCallback(
    PhoenixUtils.handleResponse(PhoenixUtils.decodeBody(D.array(SquadShort.codec).decode))(
      flow(AsyncState.Success, setState)
    ),
    []
  )

  const [, channel] = useChannel(user.token, 'squads', { onJoinSuccess, onUpdate: onJoinSuccess })

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
              <tr key={SquadId.unwrap(squad.id)}>
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
    }
  }
}

const idCodec = D.type({
  id: SquadId.codec as D.Decoder<SquadId>
})
