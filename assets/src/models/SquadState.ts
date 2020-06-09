import * as D from 'io-ts/lib/Decoder'

import { Game } from './game/Game'
import { Lobby } from './lobby/Lobby'

export namespace SquadState {
  export const codec = D.union(
    D.tuple(D.literal('lobby'), Lobby.codec),
    D.tuple(D.literal('game'), Game.codec)
  )
}

export type SquadState = D.TypeOf<typeof SquadState.codec>
