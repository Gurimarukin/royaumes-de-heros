import * as D from 'io-ts/lib/Decoder'

export namespace SquadShort {
  export const codec = D.type({
    id: D.string,
    stage: D.union(D.literal('lobby'), D.literal('game')),
    // eslint-disable-next-line @typescript-eslint/camelcase
    n_players: D.number
  })
}

export type SquadShort = D.TypeOf<typeof SquadShort.codec>
