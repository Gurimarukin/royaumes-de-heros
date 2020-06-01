import * as t from 'io-ts'

export namespace GameState {
  export const codec = t.unknown
}

export type GameState = t.TypeOf<typeof GameState.codec>
