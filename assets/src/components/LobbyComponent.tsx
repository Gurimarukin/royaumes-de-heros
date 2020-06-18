/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useContext, useCallback } from 'react'

import { Link } from './Link'
import { Router } from './Router'
import { ChannelContext } from '../contexts/ChannelContext'
import { UserContext } from '../contexts/UserContext'
import { CallMessage } from '../models/CallMessage'
import { Lobby } from '../models/lobby/Lobby'
import { Future, pipe } from '../utils/fp'

interface Props {
  readonly state: Lobby
}

export const LobbyComponent: FunctionComponent<Props> = ({ state }) => {
  const user = useContext(UserContext)
  const { call } = useContext(ChannelContext)

  const play = useCallback(() => pipe(CallMessage.startGame, call, Future.runUnsafe), [call])

  return (
    <div>
      <Link to={Router.routes.squads}>retour</Link>
      <div>{user.name}</div>
      <pre>{JSON.stringify(['lobby', state], null, 2)}</pre>
      <button onClick={play}>Jouer</button>
    </div>
  )
}
