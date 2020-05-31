import * as t from 'io-ts'

export type Squad = t.TypeOf<typeof Squad.codec>

export namespace Squad {
  export const codec = t.strict({
    id: t.string,
    stage: t.union([t.literal('lobby'), t.literal('game')]),
    n_players: t.number
  })
}
