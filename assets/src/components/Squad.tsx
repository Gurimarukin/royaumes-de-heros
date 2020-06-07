/** @jsx jsx */
import * as D from 'io-ts/lib/Decoder'
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext, useCallback } from 'react'

import { Link } from './Link'
import { Router } from './Router'
import { LobbyComponent } from './LobbyComponent'
import { GameComponent } from './game/GameComponent'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { Diff } from '../models/Diff'
import { SquadState } from '../models/SquadState'
import { SquadEvent } from '../models/SquadEvent'
import { pipe, Either, Future, List } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'

interface Props {
  readonly id: string
}

const stateWithEvent = D.tuple(SquadState.codec, SquadEvent.codec)

export const Squad: FunctionComponent<Props> = ({ id }) => {
  const user = useContext(UserContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadState>>(AsyncState.Loading)
  const [_events, setEvents] = useState<Diff<SquadEvent, null>[]>([])

  const appendEvent = useCallback((event: SquadEvent) => {
    if (event !== null) {
      setEvents(_ => List.snoc(_, event))
      console.log(SquadEvent.pretty()(event))
    }
  }, [])

  const onJoinError = useCallback(
    PhoenixUtils.handleResponse(ChannelError.codec.decode)(error => {
      if (error.status === 403 || error.status === 404) channel.leave()
      pipe(error, AsyncState.Error, setState)
    }),
    []
  )

  const onUpdate = useCallback(
    PhoenixUtils.handleResponse(PhoenixUtils.decodeBody(stateWithEvent.decode))(
      ([state, event]) => {
        setState(AsyncState.Success(state))
        appendEvent(event)
      }
    ),
    []
  )

  const [, channel] = useChannel(user.token, `squad:${id}`, { onJoinError, onUpdate })

  return pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))

  function onLoading(): JSX.Element {
    return (
      <div>
        <Link to={Router.routes.squads}>retour</Link>
        <div>Loading...</div>
      </div>
    )
  }

  function onError(error: ChannelError): JSX.Element {
    return (
      <div>
        <Link to={Router.routes.squads}>retour</Link>
        <pre>Error: {JSON.stringify(error, null, 2)}</pre>
      </div>
    )
  }

  function onSuccess(state: SquadState): JSX.Element {
    switch (state[0]) {
      case 'lobby':
        return <LobbyComponent call={call} state={state[1]} />

      case 'game':
        return <GameComponent call={call} game={state[1]} />
    }
  }

  function call(msg: any): Future<Either<void, void>> {
    return pipe(
      () => channel.push('call', msg),
      PhoenixUtils.pushToFuture,
      Future.map(
        Either.bimap(
          _ => appendEvent('error'),
          _ => {}
        )
      )
    )
  }
}

interface PartialPlayer {
  readonly name: string
}
