/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { PartialPlayer } from '../PlayerZones'
import { params } from '../../../params'
import { Rectangle } from '../../../models/game/geometry/Rectangle'
import { Referential } from '../../../models/game/geometry/Referential'
import { pipe } from '../../../utils/fp'

interface Props {
  readonly playerRef: Referential
  readonly player: PartialPlayer
}

export const Hero: FunctionComponent<Props> = ({ playerRef, player: { name, hp } }) => {
  const [left, top] = pipe(
    playerRef,
    Referential.combine(Referential.fightZone),
    Referential.coord(Rectangle.card([0, params.fightZone.innerHeight - params.card.height]))
  )
  return (
    <div css={styles.container} style={{ left, top }}>
      <div css={styles.hp}>{hp}</div>
      <div css={styles.name}>{name}</div>
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
    backgroundImage: "url('/images/counter_green.png')",
    backgroundSize: '100% 100%',
    color: 'wheat',
    overflow: 'hidden',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  }),

  hp: css({
    textShadow: '0 0 10px black',
    fontSize: '4.33em',
    fontWeight: 'bold'
  }),

  name: css({
    position: 'absolute',
    bottom: 0,
    width: '100%',
    fontSize: '3em',
    textAlign: 'center',
    padding: '2% 0 3%',
    background: '#001621',
    opacity: 0.9
  })
}
