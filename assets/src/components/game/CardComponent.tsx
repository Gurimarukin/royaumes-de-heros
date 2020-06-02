/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useContext } from 'react'
import { animated } from 'react-spring'

import { UserContext } from '../../contexts/UserContext'
import { Card } from '../../models/game/Card'
import { CardsData } from '../../utils/CardsData'

interface Props {
  readonly call: (msg: any) => void
  readonly card: Card
  readonly style?: React.CSSProperties
}

export const CardComponent: FunctionComponent<Props> = ({ call, card, style }) => {
  const user = useContext(UserContext)

  return (
    <div css={styles.container} style={style}>
      <img src={CardsData[card.key].image}></img>
    </div>
  )
}

export const AnimatedCardComponent = animated(CardComponent)

const styles = {
  container: css({
    position: 'absolute',
    borderRadius: 24,
    overflow: 'hidden'
  })
}
