import * as D from 'io-ts/Decoder'

import { Effect } from './Effect'

export namespace PendingInteraction {
  export const codec = D.union(
    D.literal('discard_card'),
    D.literal('draw_then_discard'),
    D.literal('prepare_champion'),
    D.literal('put_card_from_discard_to_deck'),
    D.literal('put_champion_from_discard_to_deck'),
    D.literal('stun_champion'),
    D.literal('target_opponent_to_discard'),
    D.tuple(
      D.literal('sacrifice_from_hand_or_discard'),
      D.type({
        amount: D.number
      })
    ),
    D.tuple(D.literal('select_effect'), D.array(Effect.codec))
  )
}

export type PendingInteraction = D.TypeOf<typeof PendingInteraction.codec>
