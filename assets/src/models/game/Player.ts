import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { PendingInteraction } from './PendingInteraction'
import { Unknown } from '../Unknown'
import { WithId } from '../WithId'

export namespace Player {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    pending_interactions: D.array(PendingInteraction.codec),
    temporary_effects: D.array(Unknown.codec),
    discard_phase_done: D.boolean,
    name: D.string,
    hp: D.number,
    max_hp: D.number,
    gold: D.number,
    combat: D.number,
    hand: D.array(WithId.codec(Card.codec)),
    deck: D.number,
    discard: D.array(WithId.codec(Card.codec)),
    fight_zone: D.array(WithId.codec(Card.codec))
    /* eslint-enable @typescript-eslint/camelcase */
  })
}

export type Player = D.TypeOf<typeof Player.codec>
