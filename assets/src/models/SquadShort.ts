import * as D from 'io-ts/lib/Decoder'

export namespace SquadShort {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    id: D.string,
    stage: D.union(D.literal('lobby'), D.literal('game')),
    n_players: D.number
    /* eslint-disable @typescript-eslint/camelcase */
  })
}

export type SquadShort = D.TypeOf<typeof SquadShort.codec>
