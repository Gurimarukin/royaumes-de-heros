import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { OtherPlayer } from './OtherPlayer'
import { PendingInteraction } from './PendingInteraction'
import { Player } from './Player'
import { WithId } from '../WithId'
import { Maybe, List } from '../../utils/fp'

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

  export function pendingInteraction(game: Game): Maybe<PendingInteraction> {
    return List.head(game.player[1].pending_interactions)
  }
}

export type Game = D.TypeOf<typeof Game.codec>
