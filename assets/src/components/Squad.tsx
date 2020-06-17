/** @jsx jsx */
import * as D from 'io-ts/lib/Decoder'
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext, useCallback } from 'react'

import { Link } from './Link'
import { Loading } from './Loading'
import { Router } from './Router'
import { LobbyComponent } from './LobbyComponent'
import { Game } from './game/Game'
import { CardDatasContext } from '../contexts/CardDatasContext'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { CallMessage } from '../models/CallMessage'
import { ChannelError } from '../models/ChannelError'
import { SquadId } from '../models/SquadId'
import { SquadState } from '../models/SquadState'
import { SquadEvent } from '../models/SquadEvent'
import { pipe, Either, Future, List, Maybe, flow } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'

interface Props {
  readonly id: SquadId
}

const stateWithEvent = D.tuple(SquadState.codec, SquadEvent.codec)

export const Squad: FunctionComponent<Props> = ({ id }) => {
  const user = useContext(UserContext)
  const cardDatas = useContext(CardDatasContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadState>>(AsyncState.Loading)
  const [events, setEvents] = useState<[number, string][]>([])

  const appendEvent = useCallback(
    (event: SquadEvent) => {
      pipe(
        SquadEvent.pretty(cardDatas)(event),
        Maybe.map(e => setEvents(flow(List.takeRight(99), _ => List.snoc(_, [Date.now(), e]))))
      )
    },
    [cardDatas]
  )

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

  const [, channel] = useChannel(user.token, `squad:${id}`, {
    onJoinError,
    onUpdate
  })

  return pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))

  function onLoading(): JSX.Element {
    return <Loading />
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
        return <Game call={call} game={state[1]} events={events} />
    }
  }

  function call(msg: CallMessage): Future<Either<unknown, unknown>> {
    return pipe(
      () => channel.push('call', (msg as unknown) as object),
      PhoenixUtils.pushToFuture,
      Future.map(
        Either.bimap(
          _ => {
            appendEvent('error')
            return _
          },
          _ => _
        )
      )
    )
  }
}
