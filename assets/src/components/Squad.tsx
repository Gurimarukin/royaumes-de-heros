/** @jsx jsx */
import { jsx } from '@emotion/core'
import { Lazy } from 'fp-ts/function'
import * as D from 'io-ts/Decoder'
import { Push } from 'phoenix'
import { FunctionComponent, useCallback, useContext, useState } from 'react'

import { CardDatasContext } from '../contexts/CardDatasContext'
import { ChannelContext } from '../contexts/ChannelContext'
import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { CallMessage } from '../models/CallMessage'
import { ChannelError } from '../models/ChannelError'
import { SquadEvent } from '../models/SquadEvent'
import { SquadId } from '../models/SquadId'
import { SquadState } from '../models/SquadState'
import { Either, Future, List, Maybe, flow, pipe } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'
import { Error } from './Error'
import { Game } from './game/Game'
import { Loading } from './Loading'
import { Lobby } from './lobby/Lobby'
import { Router } from './Router'

interface Props {
  readonly id: SquadId
}

const stateWithEvent = D.tuple(SquadState.codec, SquadEvent.codec)

export const Squad: FunctionComponent<Props> = ({ id }) => {
  const { user } = useContext(UserContext)
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

  const pushToFuture = useCallback(
    (push: Lazy<Push>): Future<Either<unknown, unknown>> =>
      pipe(
        push,
        PhoenixUtils.pushToFuture,
        Future.map(
          Either.mapLeft(_ => {
            appendEvent('error')
            return _
          })
        )
      ),
    [appendEvent]
  )

  const call = useCallback(
    (msg: CallMessage): Future<Either<unknown, unknown>> =>
      pushToFuture(() => channel.push('call', (msg as unknown) as object)),
    [channel, pushToFuture]
  )

  const leave = useCallback(
    (): Future<Either<unknown, unknown>> => pushToFuture(() => channel.push('leave', {})),
    [channel, pushToFuture]
  )

  const onLoading = useCallback((): JSX.Element => <Loading />, [])

  const onError = useCallback(
    (error: ChannelError): JSX.Element => (
      <Error
        error={error}
        messages={{
          403: 'Impossible de rejoindre cette partie',
          404: 'Impossible de trouver cette partie'
        }}
        link={[Router.routes.home, 'retour']}
      />
    ),
    []
  )

  const onSuccess = useCallback(
    (state: SquadState): JSX.Element => {
      switch (state[0]) {
        case 'lobby':
          return <Lobby lobby={state[1]} events={events} />
        case 'game':
          return <Game game={state[1]} events={events} />
      }
    },
    [events]
  )

  return (
    <ChannelContext.Provider value={{ call, leave }}>
      {pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))}
    </ChannelContext.Provider>
  )
}
