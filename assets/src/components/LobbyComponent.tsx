/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useContext } from 'react'

import { Link } from './Link'
import { Router } from './Router'
import { UserContext } from '../contexts/UserContext'
import { Lobby } from '../models/lobby/Lobby'

interface Props {
  readonly call: (msg: any) => void
  readonly state: Lobby
}

export const LobbyComponent: FunctionComponent<Props> = ({ call, state }) => {
  const user = useContext(UserContext)

  return (
    <div>
      <Link to={Router.routes.squads}>retour</Link>
      <div>{user.name}</div>
      <pre>{JSON.stringify(['lobby', state], null, 2)}</pre>
      <button onClick={play}>Jouer</button>
    </div>
  )

  function play() {
    call('start_game')
  }
}