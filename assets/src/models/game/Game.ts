import * as D from 'io-ts/Decoder'

import { List, Maybe } from '../../utils/fp'
import { PlayerId } from '../PlayerId'
import { Card } from './Card'
import { CardId } from './CardId'
import { OtherPlayer } from './OtherPlayer'
import { PendingInteraction } from './PendingInteraction'
import { Player } from './Player'

export namespace Game {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    player: D.tuple(PlayerId.codec, Player.codec),
    other_players: D.array(D.tuple(PlayerId.codec, OtherPlayer.codec)),
    current_player: PlayerId.codec,
    gems: D.array(D.tuple(CardId.codec, Card.codec)),
    market: D.array(D.tuple(CardId.codec, Card.codec)),
    market_deck: D.number,
    cemetery: D.array(D.tuple(CardId.codec, Card.codec))
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
