import * as D from 'io-ts/Decoder'

export namespace Effect {
  export const codec = D.union(
    D.tuple(D.literal('add_combat'), D.number),
    D.tuple(D.literal('add_gold'), D.number),
    D.tuple(D.literal('heal'), D.number),
    D.tuple(D.literal('heal_for_champions'), D.tuple(D.number, D.number))
  )

  export function pretty(): (effect: Effect) => string {
    return effect => {
      switch (effect[0]) {
        case 'add_combat':
          return `+${effect[1]} combat`

        case 'add_gold':
          return `+${effect[1]} or`

        case 'heal':
          return `+${effect[1]} soin`

        case 'heal_for_champions':
          const [base, perChampion] = effect[1]
          const championsInFightZone = 0 // TODO
          return `+${base + perChampion * championsInFightZone} soin`
      }
    }
  }
}

export type Effect = D.TypeOf<typeof Effect.codec>
