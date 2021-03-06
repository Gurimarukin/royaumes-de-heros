import * as D from 'io-ts/Decoder'

import { Unknown } from '../Unknown'
import { Card } from './Card'
import { CardId } from './CardId'
import { PendingInteraction } from './PendingInteraction'

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
    hand: D.array(D.tuple(CardId.codec, Card.codec)),
    deck: D.number,
    discard: D.array(D.tuple(CardId.codec, Card.codec)),
    fight_zone: D.array(D.tuple(CardId.codec, Card.codec))
    /* eslint-enable @typescript-eslint/camelcase */
  })

  export function isAlive(player: Player): boolean {
    return player.hp > 0
  }
}

export type Player = D.TypeOf<typeof Player.codec>
