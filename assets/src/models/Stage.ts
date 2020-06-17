import * as D from 'io-ts/lib/Decoder'

export namespace Stage {
  export const codec = D.union(D.literal('lobby'), D.literal('game'))
}

export type Stage = D.TypeOf<typeof Stage.codec>
