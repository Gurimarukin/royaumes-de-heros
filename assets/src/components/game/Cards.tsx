/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, Fragment } from 'react'

import { CardComponent, HiddenCard } from './CardComponent'
import { params } from '../../params'
import { WithId } from '../../models/WithId'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Coord } from '../../models/game/geometry/Coord'
import { Rectangle } from '../../models/game/geometry/Rectangle'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe, List } from '../../utils/fp'

interface Props {
  readonly call: (msg: any) => void
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, WithId<OtherPlayer>][]
}

type Zone = 'market' | 'hand' | 'fightZone'

export const Cards: FunctionComponent<Props> = ({
  call,
  game,
  referentials,
  zippedOtherPlayers
}) => {
  const [_playerId, player] = game.player

  const marketLeft = params.market.borderWidth + params.market.padding
  const marketTop = marketLeft
  const cardMarginX2 = 2 * params.card.margin
  const cardHeightPlusCardMargin = params.card.height + params.card.margin

  return (
    <div>
      {game.market.map(
        card(
          referentials.market,
          i => [marketLeft, cardMarginX2 + (i + 1) * cardHeightPlusCardMargin],
          'market'
        )
      )}
      {game.gems.map(card(referentials.market, _ => [marketLeft, marketTop], 'market'))}
      {player.hand.map(
        card(
          referentials.player,
          i => [(i + 2) * params.card.width, params.playerZone.height - params.card.height],
          'hand'
        )
      )}
      {player.fight_zone.map(
        card(referentials.player, i => [(i + 1) * params.card.width, 0], 'fightZone')
      )}
      {zippedOtherPlayers.map(([referential, [playerId, player]]) => (
        <Fragment key={playerId}>
          {List.range(2, player.hand + 1).map(
            hidden(referential, i => [
              i * params.card.width,
              params.playerZone.height - params.card.height
            ])
          )}
        </Fragment>
      ))}
    </div>
  )

  function card(
    referential: Referential,
    coord: (i: number) => Coord,
    zone: Zone
  ): (card: [string, Card], i: number) => JSX.Element {
    return ([cardId, card], i) => {
      const [left, top] = pipe(referential, Referential.coord(Rectangle.card(coord(i))))

      const onLeftClick = zone === 'hand' ? playCard(cardId) : undefined

      return (
        <CardComponent key={cardId} card={card} onLeftClick={onLeftClick} style={{ left, top }} />
      )
    }
  }

  function hidden(
    referential: Referential,
    coord: (i: number) => Coord
  ): (i: number) => JSX.Element {
    return i => {
      const [left, top] = pipe(referential, Referential.coord(Rectangle.card(coord(i))))
      return <HiddenCard key={i} style={{ left, top }} />
    }
  }

  function playCard(id: string): () => void {
    return () => call(['play_card', id])
  }
}
