/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, Fragment } from 'react'

import { CardComponent, HiddenCard } from './CardComponent'
import { params } from '../../params'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'
import { Coord } from '../../models/game/geometry/Coord'
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

export const Cards: FunctionComponent<Props> = ({ call, game, referentials }) => {
  const [playerId, player] = game.player
  const otherPlayers = List.zip(referentials.others, game.other_players)

  return (
    <div>
      {referential('lightblue')(referentials.player)}
      {referentials.others.map(referential('red'))}
      {referential('lightgreen')(referentials.market)}

      {game.market.map(card(referentials.market, i => [i * params.card.width, 0]))}
      {game.gems.map(card(referentials.market, _ => [5 * params.card.width, 0]))}
      {player.hand.map(
        card(referentials.player, i => [
          i * params.card.width,
          params.playerZone.height - params.card.height
        ])
      )}
      {otherPlayers.map(([referential, [playerId, player]]) => (
        <Fragment key={playerId}>
          {List.range(0, player.hand - 1).map(hidden(referential, i => [i * params.card.width, 0]))}
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
    coord: (i: number) => Coord
  ): (card: [string, Card], i: number) => JSX.Element {
    return ([cardId, card], i) => {
      const [left, top] = pipe(referential, Referential.coord(coord(i)))
      return <CardComponent key={cardId} card={card} call={call} style={{ left, top }} />
    }
  }

  function hidden(
    referential: Referential,
    coord: (i: number) => Coord
  ): (i: number) => JSX.Element {
    return i => {
      const [left, top] = pipe(referential, Referential.coord(coord(i)))
      return <HiddenCard key={i} style={{ left, top }} />
    }
  }
}

const styles = {
  referential: (color: string) =>
    css({
      position: 'absolute',
      border: `2px solid ${color}`
    })
}
