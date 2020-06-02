import * as D from 'io-ts/lib/Decoder'

import { Game } from './game/Game'
import { Lobby } from './lobby/Lobby'
import { pipe, Either } from '../utils/fp'

export namespace SquadState {
  export const codec: D.Decoder<SquadState> = {
    decode: (u: unknown) =>
      pipe(
        D.tuple(D.literal('lobby'), Lobby.codec).decode(u),
        Either.alt<D.DecodeError, SquadState>(() =>
          D.tuple(D.literal('game'), Game.codec).decode(u)
        )
      )
  }
}

export type SquadState = ['lobby', Lobby] | ['game', Game]
