import * as t from 'io-ts'

export namespace Game {
  export const codec = t.strict({})
}

export type Game = t.TypeOf<typeof Game.codec>
