/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { params } from '../../../params'
import { Rectangle } from '../../../models/game/geometry/Rectangle'
import { Referential } from '../../../models/game/geometry/Referential'
import { pipe } from '../../../utils/fp'

interface Props {
  readonly playerRef: Referential
  readonly current: boolean
}

export const FightZone: FunctionComponent<Props> = ({ playerRef, current }) => {
  const [left, top] = pipe(playerRef, Referential.coord(Rectangle.fightZone([0, 0])))
  return (
    <div css={styles.container} className={current ? 'current' : undefined} style={{ left, top }} />
  )
}

const styles = {
  container: css({
    position: 'absolute',
    width: params.fightZone.width,
    height: params.fightZone.height,
    border: `${params.fightZone.borderWidth}px solid darkgoldenrod`,
    borderStyle: `groove ridge ridge groove`,
    boxShadow: '0 0 6px black',
    backgroundImage: "url('/images/hardened_clay_stained_blue.png')",

    '&.current': {
      backgroundImage: "url('/images/hardened_clay_stained_purple.png')"
    }
  })
}
