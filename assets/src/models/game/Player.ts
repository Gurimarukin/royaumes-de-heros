import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { Unknown } from '../Unknown'
import { WithId } from '../WithId'

export namespace Player {
  export const codec = D.type({
    pending_interactions: D.array(Unknown.codec),
    temporary_effects: D.array(Unknown.codec),
    discard_phase_done: D.boolean,
    hp: D.number,
    max_hp: D.number,
    gold: D.number,
    combat: D.number,
    hand: D.array(WithId.codec(Card.codec)),
    deck: D.number,
    discard: D.array(WithId.codec(Card.codec)),
    fight_zone: D.array(WithId.codec(Card.codec))
  })
}

export type Player = D.TypeOf<typeof Player.codec>