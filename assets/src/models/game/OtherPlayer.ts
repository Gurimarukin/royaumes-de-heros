import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { Unknown } from '../Unknown'
import { WithId } from '../WithId'

export namespace OtherPlayer {
  export const codec = D.type({
    temporary_effects: D.array(Unknown.codec),
    hp: D.number,
    max_hp: D.number,
    gold: D.number,
    combat: D.number,
    hand: D.number,
    deck: D.number,
    discard: D.array(WithId.codec(Card.codec)),
    fight_zone: D.array(WithId.codec(Card.codec))
  })
}

export type OtherPlayer = D.TypeOf<typeof OtherPlayer.codec>
