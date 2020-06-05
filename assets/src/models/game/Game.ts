import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { OtherPlayer } from './OtherPlayer'
import { Player } from './Player'
import { WithId } from '../WithId'

export namespace Game {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    player: WithId.codec(Player.codec),
    other_players: D.array(WithId.codec(OtherPlayer.codec)),
    current_player: D.string,
    gems: D.array(WithId.codec(Card.codec)),
    market: D.array(WithId.codec(Card.codec)),
    market_deck: D.number,
    cemetery: D.array(WithId.codec(Card.codec))
    /* eslint-enable @typescript-eslint/camelcase */
  })

  export function isCurrentPlayer(game: Game): boolean {
    return game.current_player === game.player[0]
  }
}

export type Game = D.TypeOf<typeof Game.codec>
