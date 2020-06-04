/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { params } from '../../params'
import { Rectangle } from '../../models/game/geometry/Rectangle'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe } from '../../utils/fp'

export const MarketZone: FunctionComponent = () => {
  const [left, right] = pipe(Referential.market, Referential.coord(Rectangle.market([0, 0])))
  return <div css={styles.container} style={{ left, right }} />
}

const styles = {
  container: css({
    position: 'absolute',
    width: params.market.width,
    height: params.market.height,
    border: `${params.market.borderWidth}px solid darkred`,
    backgroundImage: "url('/images/wool_colored_red.png')"
  })
}
