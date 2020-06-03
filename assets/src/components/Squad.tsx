/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext, useCallback } from 'react'

import { LobbyComponent } from './LobbyComponent'
import { GameComponent } from './game/GameComponent'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { SquadState } from '../models/SquadState'
import { pipe, flow, Future, Task, inspect, Either } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'

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

  return pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))

  function onLoading(): JSX.Element {
    return <div>Loading...</div>
  }

  function onError(error: ChannelError): JSX.Element {
    return <pre>Error: {JSON.stringify(error, null, 2)}</pre>
  }

  function onSuccess(state: SquadState): JSX.Element {
    switch (state[0]) {
      case 'lobby':
        return <LobbyComponent call={call} state={state[1]} />

      case 'game':
        return <GameComponent call={call} game={state[1]} />
    }
  }

  function call(msg: any): void {
    console.log('call:', msg)
    pipe(
      channel.push('call', msg),
      PhoenixUtils.channelToFuture,
      Task.map(
        Either.fold(
          _ => 'error',
          _ => 'ok'
        )
      ),
      Task.map(_ => console.log(`response from call: ${_}`)),
      Task.run
    )
  }
}
