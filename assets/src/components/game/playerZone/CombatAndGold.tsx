/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { PartialPlayer } from '../PlayerZones'
import { Coin, Swords } from '../../icons'
import { params } from '../../../params'
import { Rectangle } from '../../../models/game/geometry/Rectangle'
import { Referential } from '../../../models/game/geometry/Referential'
import { pipe } from '../../../utils/fp'

interface Props {
  readonly playerRef: Referential
  readonly player: PartialPlayer
}

export const CombatAndGold: FunctionComponent<Props> = ({
  playerRef,
  player: { combat, gold }
}) => {
  const [left, top] = pipe(
    playerRef,
    Referential.combine(Referential.bottomZone),
    Referential.coord(Rectangle.card([0, 0]))
  )
  return (
    <div css={styles.container} style={{ left, top }}>
      <div css={[styles.section, styles.combat]}>
        <Swords /> <span>{combat}</span>
      </div>
      <div css={[styles.section, styles.gold]}>
        <Coin /> <span>{gold}</span>
      </div>
    </div>
  )
}

const styles = {
  container: css({
    position: 'absolute',
    width: params.card.width,
    height: params.card.height,
    borderRadius: params.card.borderRadius,
    boxShadow: '0 0 4px black',
    overflow: 'hidden',
    fontSize: '3.5em',
    display: 'flex',
    flexDirection: 'column'
  }),

  section: css({
    flexGrow: 1,
    display: 'flex',
    alignItems: 'center',
    fontWeight: 'bold',

    '& > *': {
      flexGrow: 1,
      flexBasis: 0,
      display: 'flex',
      justifyContent: 'center'
    }
  }),

  combat: css({
    backgroundColor: 'darkred',
    color: 'bisque',

    '& > svg': {
      transform: 'rotate(180deg)'
    }
  }),

  gold: css({
    backgroundColor: '#0a2354',
    color: 'gold'
  })
}
