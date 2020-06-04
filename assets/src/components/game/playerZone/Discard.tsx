/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Skull } from '../../icons'
import { params } from '../../../params'
import { Rectangle } from '../../../models/game/geometry/Rectangle'
import { Referential } from '../../../models/game/geometry/Referential'
import { pipe } from '../../../utils/fp'

interface Props {
  readonly playerRef: Referential
}

export const Discard: FunctionComponent<Props> = ({ playerRef }) => {
  const [left, top] = pipe(
    playerRef,
    Referential.combine(Referential.bottomZone),
    Referential.coord(Rectangle.card([params.card.widthPlusMargin, 0]))
  )
  return (
    <div css={styles.container} style={{ left, top }}>
      <Skull />
    </div>
  )
}

const styles = {
  container: css({
    position: 'absolute',
    width: params.card.width,
    height: params.card.height,
    borderRadius: params.card.borderRadius,
    border: `${params.fightZone.borderWidth}px dashed #555555`,
    backgroundColor: 'rgba(0, 0, 0, 0.3)',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    fontSize: '10em',
    color: '#555555',

    '& > svg': {
      '& .secondary': {
        opacity: 1,
        color: 'darkgrey'
      }
    }
  })
}
