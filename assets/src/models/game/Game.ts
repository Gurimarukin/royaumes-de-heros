import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { OtherPlayer } from './OtherPlayer'
import { Player } from './Player'
import { WithId } from '../WithId'

export namespace Game {
  export const codec = D.type({
    player: WithId.codec(Player.codec),
    other_players: D.array(WithId.codec(OtherPlayer.codec)),
    current_player: D.string,
    gems: D.array(WithId.codec(Card.codec)),
    market: D.array(WithId.codec(Card.codec)),
    market_deck: D.number,
    cemetery: D.array(WithId.codec(Card.codec))
  })
}

export type Game = D.TypeOf<typeof Game.codec>
