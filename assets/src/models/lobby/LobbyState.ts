import * as t from 'io-ts'

import { LobbyPlayer } from './LobbyPlayer'

export namespace LobbyState {
  export const codec = t.strict({
    owner: t.string,
    players: t.array(t.tuple([t.string, LobbyPlayer.codec])),
    ready: t.boolean
  })
}

export type LobbyState = t.TypeOf<typeof LobbyState.codec>
