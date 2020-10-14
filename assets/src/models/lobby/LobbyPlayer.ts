import * as D from 'io-ts/Decoder'

export namespace LobbyPlayer {
  export const codec = D.type({
    name: D.string
  })
}

export type LobbyPlayer = D.TypeOf<typeof LobbyPlayer.codec>
