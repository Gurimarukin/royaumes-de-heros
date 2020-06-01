import * as t from 'io-ts'

import { GameState } from './game/GameState'
import { LobbyState } from './lobby/LobbyState'

export namespace SquadState {
  export const codec = t.union([
    t.tuple([t.literal('lobby'), LobbyState.codec]),
    t.tuple([t.literal('game'), GameState.codec])
  ])
}

export type SquadState = t.TypeOf<typeof SquadState.codec>
