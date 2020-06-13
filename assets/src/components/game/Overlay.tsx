/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useCallback } from 'react'

import { params } from '../../params'
import { PlayerId } from '../../models/PlayerId'
import { Card } from '../../models/game/Card'
import { CardId } from '../../models/game/CardId'
import { Game } from '../../models/game/Game'
import { Referentials } from '../../models/game/Referentials'
import { Coord } from '../../models/game/geometry/Coord'
import { Rectangle } from '../../models/game/geometry/Rectangle'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe } from '../../utils/fp'

interface Props {
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, [PlayerId, PartialPlayer]][]
}

export interface PartialPlayer {
  readonly discard: [CardId, Card][]
  readonly deck: number
}

const width = params.card.width * 0.3
const height = width

const HIDDEN = 'hidden'

export const Overlay: FunctionComponent<Props> = ({ game, referentials, zippedOtherPlayers }) => {
  const counter = useCallback((ref: Referential, count: number, coord: Coord): JSX.Element => {
    const [left, top] = pipe(
      ref,
      Referential.combine(Referential.bottomZone),
      Referential.coord(Rectangle(coord, width, height))
    )
    return (
      <div css={styles.counter} className={count === 0 ? HIDDEN : undefined} style={{ left, top }}>
        {count}
      </div>
    )
  }, [])

  const overlay = useCallback(
    (ref: Referential, id: PlayerId, player: PartialPlayer): JSX.Element => (
      <div key={PlayerId.unwrap(id)}>
        {counter(ref, player.discard.length, [
          (params.card.width - width) / 2,
          params.card.height - height
        ])}
        {counter(ref, player.deck, [
          params.bottomZone.width - (params.card.width + width) / 2,
          params.card.height - height
        ])}
      </div>
    ),
    [counter]
  )

  const [playerId, player] = game.player

  return (
    <div>
      {overlay(referentials.player, playerId, player)}
      {zippedOtherPlayers.map(([ref, [id, player]]) => overlay(ref, id, player))}
    </div>
  )
}

const styles = {
  counter: css({
    position: 'absolute',
    width,
    height,
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    fontSize: '2.67em',
    backgroundColor: '#444444',
    color: 'white',
    borderRadius: '50%',
    transition: 'all 0.2s',

    [`&.${HIDDEN}`]: {
      opacity: 0,
      visibility: 'hidden'
    },

    '&::after': {
      content: `''`,
      position: 'absolute',
      width: 'calc(100% - 6px)',
      height: 'calc(100% - 6px)',
      left: '2px',
      top: '2px',
      borderRadius: '50%',
      border: '2px solid black'
    }
  })
}
