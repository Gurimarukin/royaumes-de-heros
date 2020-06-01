/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext, useCallback } from 'react'

import { LobbyState } from '../models/lobby/LobbyState'

interface Props {
  readonly call: (msg: any) => void
  readonly state: LobbyState
}

export const Lobby: FunctionComponent<Props> = ({ call, state }) => {
  return (
    <div>
      <pre>{JSON.stringify(['lobby', state], null, 2)}</pre>
      <button onClick={play}>Jouer</button>
    </div>
  )

  function play() {
    call('start_game')
  }
}
