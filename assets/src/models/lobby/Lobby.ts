import * as D from 'io-ts/lib/Decoder'

import { LobbyPlayer } from './LobbyPlayer'
import { WithId } from '../WithId'

export namespace Lobby {
  export const codec = D.type({
    owner: D.string,
    players: D.array(WithId.codec(LobbyPlayer.codec)),
    ready: D.boolean
  })
}

export type Lobby = D.TypeOf<typeof Lobby.codec>
