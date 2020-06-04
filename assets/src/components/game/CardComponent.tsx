/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, ReactNode, useCallback } from 'react'
import { animated } from 'react-spring'

import { params } from '../../params'
import { Card } from '../../models/game/Card'
import { CardData } from '../../utils/CardData'
import { pipe, Maybe } from '../../utils/fp'

interface CommonProps {
  readonly style?: React.CSSProperties
}

type CardProps = {
  readonly card: Card
} & GeneralCardProps &
  CommonProps

export interface GeneralCardProps {
  readonly onLeftClick?: React.MouseEventHandler<HTMLDivElement>
}

export const CardComponent: FunctionComponent<CardProps> = ({ card, onLeftClick, style }) => {
  const onClick = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      if (onLeftClick !== undefined && e.button === 0) onLeftClick(e)
    },
    [onLeftClick]
  )

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
    overflow: 'hidden',

    '& > img': {
      width: '100%',
      height: '100%'
    }
  })
}
