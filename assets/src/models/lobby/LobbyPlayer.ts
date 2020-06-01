import * as t from 'io-ts'

export namespace LobbyPlayer {
  export const codec = t.strict({
    name: t.string
  })
}

export type LobbyPlayer = t.TypeOf<typeof LobbyPlayer.codec>
