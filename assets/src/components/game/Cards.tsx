/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { CardComponent } from './CardComponent'
import { Game } from '../../models/game/Game'
import { Coord } from '../../models/game/geometry/Coord'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe } from '../../utils/fp'
import { params } from '../../params'

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

  return (
    <div>
      {referential('lightblue')(referentials.player)}
      {referentials.others.map(referential('red'))}
      {referential('lightgreen')(referentials.market)}

      {player.hand.map(([cardId, card], i) => {
        const [left, top] = pipe(
          referentials.player,
          Referential.coord([i * params.card.width, params.playerZone.height - params.card.height])
        )
        return <CardComponent key={cardId} card={card} call={call} style={{ left, top }} />
      })}
    </div>
  )

  function referential(color: string): (ref: Referential, key?: string | number) => JSX.Element {
    return (ref, key) => {
      const [left, top] = ref.position
      const width = ref.width
      const height = ref.height
      return (
        <div key={key} css={styles.referential(color)} style={{ left, top, width, height }}></div>
      )
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
