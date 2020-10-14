import * as D from 'io-ts/Decoder'

import { PlayerId } from '../PlayerId'
import { LobbyPlayer } from './LobbyPlayer'

export namespace Lobby {
  export const codec = D.type({
    owner: PlayerId.codec,
    players: D.array(D.tuple(PlayerId.codec, LobbyPlayer.codec)),
    ready: D.boolean
  })
}

export type Lobby = D.TypeOf<typeof Lobby.codec>
