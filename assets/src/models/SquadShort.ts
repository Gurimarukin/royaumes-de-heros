import * as t from 'io-ts'

export namespace SquadShort {
  export const codec = t.strict({
    id: t.string,
    stage: t.union([t.literal('lobby'), t.literal('game')]),
    // eslint-disable-next-line @typescript-eslint/camelcase
    n_players: t.number
  })
}

export type SquadShort = t.TypeOf<typeof SquadShort.codec>
