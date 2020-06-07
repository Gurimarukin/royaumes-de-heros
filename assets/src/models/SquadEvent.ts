import * as D from 'io-ts/lib/Decoder'

import { Unknown } from './Unknown'

export namespace SquadEvent {
  const event = D.union(
    D.literal('start_game'),
    D.literal('joined'),
    D.literal('reconnected'),
    D.literal('left'),
    Unknown.codec
  )

  export const codec = D.union(D.literal(null), D.literal('error'), D.tuple(D.string, event))

  export function pretty(): (event: SquadEvent) => string {
    return event => JSON.stringify(event)
  }
}

export type SquadEvent = D.TypeOf<typeof SquadEvent.codec>
