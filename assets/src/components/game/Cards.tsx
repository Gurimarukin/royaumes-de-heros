/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, Fragment } from 'react'

import { CardComponent, HiddenCard } from './CardComponent'
import { params } from '../../params'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'
import { Coord } from '../../models/game/geometry/Coord'
import { Rectangle } from '../../models/game/geometry/Rectangle'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe, List } from '../../utils/fp'

interface Props {
  readonly call: (msg: any) => void
  readonly game: Game
  readonly referentials: {
    readonly market: Referential
    readonly player: Referential
    readonly others: Referential[]
  }
}

type Zone = 'market' | 'hand' | 'fightZone'

export const Cards: FunctionComponent<Props> = ({ call, game, referentials }) => {
  const [playerId, player] = game.player
  const otherPlayers = List.zip(referentials.others, game.other_players)

  return (
    <div>
      {referential('lightblue')(referentials.player)}
      {referentials.others.map(referential('red'))}
      {referential('lightgreen')(referentials.market)}

      {game.market.map(card(referentials.market, i => [i * params.card.width, 0], 'market'))}
      {game.gems.map(card(referentials.market, _ => [5 * params.card.width, 0], 'market'))}
      {player.hand.map(
        card(
          referentials.player,
          i => [i * params.card.width, params.playerZone.height - params.card.height],
          'hand'
        )
      )}
      {player.fight_zone.map(
        card(referentials.player, i => [i * params.card.width, 0], 'fightZone')
      )}
      {otherPlayers.map(([referential, [playerId, player]]) => (
        <Fragment key={playerId}>
          {List.range(0, player.hand - 1).map(
            hidden(referential, i => [
              i * params.card.width,
              params.playerZone.height - params.card.height
            ])
          )}
        </Fragment>
      ))}
    </div>
  )

  function referential(color: string): (ref: Referential, key?: string | number) => JSX.Element {
    return (ref, key) => {
      const [left, top] = ref.position
      const width = ref.width
      const height = ref.height
      return <div key={key} css={styles.referential(color)} style={{ left, top, width, height }} />
    }
  }

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

const styles = {
  referential: (color: string) =>
    css({
      position: 'absolute',
      border: `2px solid ${color}`
    })
}
