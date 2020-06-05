import * as D from 'io-ts/lib/Decoder'

export namespace Effect {
  export const codec = D.union(
    D.tuple(D.literal('heal'), D.number),
    D.tuple(D.literal('heal_for_champions'), D.tuple(D.number, D.number)),
    D.tuple(D.literal('add_gold'), D.number),
    D.tuple(D.literal('add_combat'), D.number)
  )
}

export type Effect = D.TypeOf<typeof Effect.codec>
