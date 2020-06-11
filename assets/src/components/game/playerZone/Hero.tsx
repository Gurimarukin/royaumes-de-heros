/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useMemo, useCallback } from 'react'
import { animated as a } from 'react-spring'

import { PartialPlayer } from '../PlayerZones'
import { params } from '../../../params'
import { useValTransition } from '../../../hooks/useValTransition'
import { PlayerId } from '../../../models/PlayerId'
import { CallChannel, CallMessage } from '../../../models/CallMessage'
import { Game } from '../../../models/game/Game'
import { Interaction } from '../../../models/game/Interaction'
import { Rectangle } from '../../../models/game/geometry/Rectangle'
import { Referential } from '../../../models/game/geometry/Referential'
import { pipe, Future, Maybe } from '../../../utils/fp'

interface Props {
  readonly call: CallChannel
  readonly game: Game
  readonly playerRef: Referential
  readonly player: [PlayerId, PartialPlayer]
}

export const Hero: FunctionComponent<Props> = ({
  call,
  game,
  playerRef,
  player: [playerId, { name, hp }]
}) => {
  const callAndRun = useCallback((msg: CallMessage) => () => pipe(call(msg), Future.runUnsafe), [
    call
  ])

  const isOther = game.player[0] !== playerId
  const isCurrent = Game.isCurrentPlayer(game)
  const pendingInteraction = Game.pendingInteraction(game)
  const onClick = useMemo<React.MouseEventHandler | undefined>(
    () =>
      pipe(
        pendingInteraction,
        Maybe.fold(
          () =>
            isOther && isCurrent ? callAndRun(CallMessage.Attack(playerId, '__player')) : undefined,
          interaction =>
            interaction === 'target_opponent_to_discard'
              ? callAndRun(CallMessage.Interact(Interaction.TargetOpponentToDiscard(playerId)))
              : undefined
        )
      ),
    [callAndRun, isCurrent, isOther, pendingInteraction, playerId]
  )

  const transitions = useValTransition({ hp })

  const [left, top] = pipe(
    playerRef,
    Referential.combine(Referential.fightZone),
    Referential.coord(Rectangle.card([0, params.fightZone.innerHeight - params.card.height]))
  )

  return (
    <div
      onClick={onClick}
      css={styles.container}
      className={isOther ? 'attack' : undefined}
      style={{ left, top }}
    >
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
    userSelect: 'none',

    '&.attack': {
      cursor: "url('/images/cursors/sword.svg'), auto"
    }
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
