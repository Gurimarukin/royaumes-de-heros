import * as t from 'io-ts'

export namespace Squad {
  export const codec = t.strict({
    id: t.string,
    stage: t.union([t.literal('lobby'), t.literal('game')]),
    // eslint-disable-next-line @typescript-eslint/camelcase
    n_players: t.number
  })
}

export type Squad = t.TypeOf<typeof Squad.codec>
