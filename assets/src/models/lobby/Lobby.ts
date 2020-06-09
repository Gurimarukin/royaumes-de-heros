import * as D from 'io-ts/lib/Decoder'

import { LobbyPlayer } from './LobbyPlayer'
import { PlayerId } from '../PlayerId'

export namespace Lobby {
  export const codec = D.type({
    owner: D.string,
    players: D.array(D.tuple(PlayerId.codec, LobbyPlayer.codec)),
    ready: D.boolean
  })
}

export type Lobby = D.TypeOf<typeof Lobby.codec>
