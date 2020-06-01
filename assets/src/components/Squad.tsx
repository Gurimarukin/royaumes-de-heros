/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext, useCallback } from 'react'

import { Link } from './Link'
import { Lobby } from './Lobby'
import { Router } from './Router'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { SquadState } from '../models/SquadState'
import { pipe, Either, flow, Future, Task, inspect } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'
import { LobbyState } from '../models/lobby/LobbyState'

interface Props {
  readonly id: string
}

export const Squad: FunctionComponent<Props> = ({ id }) => {
  const user = useContext(UserContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadState>>(AsyncState.Loading)

  const onJoinError = useCallback(
    PhoenixUtils.handleResponse(ChannelError.codec.decode)(error => {
      if (error.status === 403 || error.status === 404) channel.leave()
      pipe(error, AsyncState.Error, setState)
    }),
    []
  )

  const onUpdate = useCallback(
    PhoenixUtils.handleResponse(PhoenixUtils.decodeBody(SquadState.codec.decode))(
      flow(AsyncState.Success, setState)
    ),
    []
  )

  const [, channel] = useChannel(user.token, `squad:${id}`, { onJoinError, onUpdate })

  return (
    <div>
      <Link to={Router.routes.squads}>retour</Link>
      <div>{user.name}</div>
      {pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))}
    </div>
  )

  function onLoading(): JSX.Element {
    return <div>Loading...</div>
  }

  function onError(error: ChannelError): JSX.Element {
    return <pre>Error: {JSON.stringify(error, null, 2)}</pre>
  }

  function onSuccess([stage, state]: SquadState): JSX.Element {
    switch (stage) {
      case 'lobby':
        return <Lobby call={call} state={state as LobbyState} />

      case 'game':
        return <pre>{JSON.stringify([stage, state], null, 2)}</pre>
    }
  }

  function call(msg: any): void {
    console.log('call:', msg)
    pipe(
      channel.push('call', msg),
      PhoenixUtils.channelToFuture,
      Task.map(inspect('response from call:')),
      Future.runUnsafe
    )
  }
}
