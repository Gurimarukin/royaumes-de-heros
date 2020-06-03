/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, ReactNode } from 'react'
import { animated } from 'react-spring'

import { params } from '../../params'
import { Card } from '../../models/game/Card'
import { CardData } from '../../utils/CardData'
import { pipe, Maybe } from '../../utils/fp'

interface CommonProps {
  readonly style?: React.CSSProperties
}

type CardProps = {
  readonly call: (msg: any) => void
  readonly card: Card
} & CommonProps

export const CardComponent: FunctionComponent<CardProps> = ({ call, card, style }) => (
  <div css={styles.container} style={style}>
    {pipe(
      CardData.get(card.key),
      Maybe.fold<CardData, ReactNode>(
        () => `carte inconnue: ${card.key}`,
        _ => <img src={_.image} />
      )
    )}
  </div>
)

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
    borderRadius: 24,
    overflow: 'hidden'
  })
}
