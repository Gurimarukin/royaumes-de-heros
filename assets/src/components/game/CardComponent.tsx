/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, ReactNode, useMemo, useCallback } from 'react'
import { animated } from 'react-spring'

import { params } from '../../params'
import { Card } from '../../models/game/Card'
import { CardData } from '../../utils/CardData'
import { pipe, Maybe, Future, Either } from '../../utils/fp'
import { Game } from '../../models/game/Game'
import { WithId } from '../../models/WithId'

interface CommonProps {
  readonly style?: React.CSSProperties
}

type CardProps = {
  readonly call: (msg: any) => Future<Either<void, void>>
  readonly game: Game
  readonly card: WithId<Card>
  readonly zone: Zone
} & CommonProps

export type Zone = ['market' | 'hand' | 'fightZone' | 'discard', IsOther]
type IsOther = boolean

type MouseEventHandler<A = HTMLElement> = (e: React.MouseEvent<A>) => void

export const CardComponent: FunctionComponent<CardProps> = ({
  call,
  game,
  card: [cardId, card],
  zone: [zone, isOther],
  style
}) => {
  const callAndRun = useCallback((msg: any) => pipe(call(msg), Future.runUnsafe), [call])
  const isCurrent = Game.isCurrentPlayer(game)
  const onClick = useMemo<MouseEventHandler | undefined>(() => {
    switch (zone) {
      case 'market':
        return isCurrent ? () => callAndRun(['buy_card', cardId]) : undefined

      case 'hand':
        return !isOther && isCurrent ? () => callAndRun(['play_card', cardId]) : undefined

      case 'fightZone':
        // TODO: if current: attack if other else ability
        return undefined

      case 'discard':
        // TODO: show discard
        return undefined
    }
  }, [callAndRun, isOther, isCurrent, cardId, zone])

  return (
    <div onClick={onClick} css={styles.container} style={style}>
      {pipe(
        CardData.get(card.key),
        Maybe.fold<CardData, ReactNode>(
          () => `carte inconnue: ${card.key}`,
          _ => <img src={_.image} />
        )
      )}
    </div>
  )
}

export const AnimatedCardComponent = animated(CardComponent)

export const HiddenCard: FunctionComponent<CommonProps> = ({ style }) => (
  <div css={styles.container} style={style}>
    <img src={CardData.hidden} />
  </div>
)

const styles = {
  container: css({
    position: 'absolute',
    width: params.card.width,
    height: params.card.height,
    borderRadius: params.card.borderRadius,
    boxShadow: '0 0 4px black',
    overflow: 'hidden',

    '& > img': {
      width: '100%',
      height: '100%'
    }
  })
}
