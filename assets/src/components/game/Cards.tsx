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
    readonly player: Referential
    readonly others: Referential[]
  }
}

export const Cards: FunctionComponent<Props> = ({ call, game, referentials }) => {
  const [playerId, player] = game.player

  return (
    <div>
      {referential(referentials.player)}
      {referentials.others.map(referential)}
      {player.hand.map(([cardId, card], i) => {
        const [left, top] = pipe(
          referentials.player,
          Referential.coord([i * params.card.width, params.playerZone.height - params.card.height])
        )
        return <CardComponent key={cardId} card={card} call={call} style={{ left, top }} />
      })}
      {/* <button onClick={play}>Jouer</button> */}
    </div>
  )

  function referential(ref: Referential, key?: string | number): JSX.Element {
    const [left, top] = ref.position
    const width = ref.width
    const height = ref.height
    return <div key={key} css={styles.referential} style={{ left, top, width, height }}></div>
  }
}

const styles = {
  referential: css({
    position: 'absolute',
    border: '5px solid red'
  })
}
