import * as D from 'io-ts/lib/Decoder'

import { Unknown } from '../Unknown'

export namespace PendingInteraction {
  export const codec = D.union(
    D.tuple(D.literal('select_effect'), Unknown.codec),
    D.literal('prepare_champion'),
    D.literal('stun_champion'),
    D.literal('put_card_from_discard_to_deck'),
    D.tuple(
      D.literal('sacrifice_from_hand_or_discard'),
      D.type({
        amount: D.number
      })
    ),
    D.literal('target_opponent_to_discard'),
    D.literal('draw_then_discard'),
    D.literal('discard_card')
  )
}

export type PendingInteraction = D.TypeOf<typeof PendingInteraction.codec>
