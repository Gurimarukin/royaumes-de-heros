/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useMemo } from 'react'
import { animated as a } from 'react-spring'

import { PartialPlayer } from '../PlayerZones'
import { params } from '../../../params'
import { useValTransition } from '../../../hooks/useValTransition'
import { PushSocket } from '../../../models/PushSocket'
import { WithId } from '../../../models/WithId'
import { Game } from '../../../models/game/Game'
import { Rectangle } from '../../../models/game/geometry/Rectangle'
import { Referential } from '../../../models/game/geometry/Referential'
import { pipe, Future } from '../../../utils/fp'

interface Props {
  readonly call: PushSocket
  readonly game: Game
  readonly playerRef: Referential
  readonly player: WithId<PartialPlayer>
}

export const Hero: FunctionComponent<Props> = ({
  call,
  game,
  playerRef,
  player: [playerId, { name, hp }]
}) => {
  const isOther = game.player[0] !== playerId
  const isCurrent = Game.isCurrentPlayer(game)
  const onClick = useMemo(
    () =>
      isOther && isCurrent
        ? () => pipe(call(['attack', playerId, '__player']), Future.runUnsafe)
        : undefined,
    [call, isOther, isCurrent, playerId]
  )

  const transitions = useValTransition({ hp })

  const [left, top] = pipe(
    playerRef,
    Referential.combine(Referential.fightZone),
    Referential.coord(Rectangle.card([0, params.fightZone.innerHeight - params.card.height]))
  )

  return (
    <div onClick={onClick} css={styles.container} style={{ left, top }}>
      {transitions.map(({ key, props }) => (
        <a.div key={key} css={styles.hp}>
          {props.hp.interpolate(_ => Math.round(_ as number))}
        </a.div>
      ))}
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
    alignItems: 'center',
    userSelect: 'none'
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
