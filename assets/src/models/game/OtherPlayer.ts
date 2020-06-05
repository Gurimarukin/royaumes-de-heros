import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { Unknown } from '../Unknown'
import { WithId } from '../WithId'

export namespace OtherPlayer {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    temporary_effects: D.array(Unknown.codec),
    name: D.string,
    hp: D.number,
    max_hp: D.number,
    gold: D.number,
    combat: D.number,
    hand: D.number,
    deck: D.number,
    discard: D.array(WithId.codec(Card.codec)),
    fight_zone: D.array(WithId.codec(Card.codec))
    /* eslint-enable @typescript-eslint/camelcase */
  })
}

export type OtherPlayer = D.TypeOf<typeof OtherPlayer.codec>
