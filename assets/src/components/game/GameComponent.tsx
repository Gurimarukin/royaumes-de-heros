/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { Lazy } from 'fp-ts/lib/function'
import { FunctionComponent, useRef, useState } from 'react'
import { useSpring, animated as a } from 'react-spring'

import { Cards } from './Cards'
import { Dialog, DialogProps } from './Dialog'
import { MarketZone } from './MarketZone'
import { PlayerZones } from './PlayerZones'
import { BaseButton } from '../BaseButton'
import { params } from '../../params'
import { usePendingInteraction } from '../../hooks/game/usePendingInteraction'
import { DialogState } from '../../models/game/DialogState'
import { Game } from '../../models/game/Game'
import { Referential } from '../../models/game/geometry/Referential'
import { List, pipe, Future, Either, Task } from '../../utils/fp'

interface Props {
  readonly call: (msg: any) => Future<Either<void, void>>
  readonly game: Game
}

interface BoardProps {
  readonly s: number
  readonly x: number
  readonly y: number
}

interface Moving {
  readonly h: -1 | 0 | 1
  readonly v: -1 | 0 | 1
}

namespace Moving {
  export function isStill({ h, v }: Moving): boolean {
    return h === 0 && v === 0
  }
}

const maxScale = 1

const moveDetect = 40
const moveStepPx = 300
const moveStepMs = 100

export const GameComponent: FunctionComponent<Props> = ({ call, game }) => {
  // navigation
  const referentials = {
    market: Referential.market,
    player: Referential.playerZone([0, 1]),
    others: Referential.otherPlayers(game.other_players.length)
  }

  const board = { width: params.board.width(referentials), height: params.board.height }

  const minScaleW = minScale(window.innerWidth, board.width)
  const minScaleH = minScale(window.innerHeight, board.height)
  const s = Math.min(minScaleW, minScaleH)
  const boardPropsRef = useRef<BoardProps>({
    s,
    x: coord(minScaleW, window.innerWidth, board.width, s, () => 0),
    y: coord(
      minScaleH,
      window.innerHeight,
      board.height,
      s,
      () => window.innerHeight - board.height * s
    )
  })
  const [props, set] = useSpring(() => boardPropsRef.current)

  const moveRef = useRef<Moving>({ h: 0, v: 0 })

  const zippedOtherPlayers = List.zip(referentials.others, game.other_players)

  // end turn
  const [endTurnSent, setEndTurnSent] = useState(false)

  // dialogue
  const [dialogState, _setDialogState] = useState<DialogState<DialogProps>>(
    DialogState.empty({ shown: false })
  )
  // const setDialogState = useCallback(
  //   (props: DialogProps) =>
  //     _setDialogState(prev =>
  //       // don't update if previous is interaction and it is show
  //       DialogState.isInteraction(prev) && prev.props.shown ? prev : DialogState.Other(props)
  //     ),
  //   []
  // )

  usePendingInteraction(call, game, _setDialogState)

  return (
    <div css={styles.container} onWheel={onWheel} onMouseMove={move} onMouseLeave={resetMove}>
      <a.div
        css={styles.board(board.width, board.height)}
        style={{ transform: props.s.interpolate(trans), left: props.x, top: props.y }}
      >
        <MarketZone />
        <PlayerZones
          call={call}
          game={game}
          referentials={referentials}
          zippedOtherPlayers={zippedOtherPlayers}
        />
        <Cards
          call={call}
          game={game}
          referentials={referentials}
          zippedOtherPlayers={zippedOtherPlayers}
        />
      </a.div>
      <BaseButton
        disabled={endTurnSent}
        onClick={endTurn}
        css={styles.endTurn}
        className={Game.isCurrentPlayer(game) ? 'current' : undefined}
      >
        Fin du tour
      </BaseButton>
      <Dialog {...dialogState.props} />
    </div>
  )

  function endTurn() {
    setEndTurnSent(true)
    pipe(
      call('discard_phase'),
      Future.chain(
        Either.fold(
          _ => Future.right(setEndTurnSent(false)),
          _ =>
            pipe(
              call('draw_phase'),
              Task.delay(1000),
              Future.map(_ => setEndTurnSent(false))
            )
        )
      ),
      Future.runUnsafe
    )
  }

  function onWheel({ deltaY, clientX, clientY }: React.WheelEvent) {
    // const zoomIn = deltaY < 0

    const { s, x, y } = boardPropsRef.current

    const minScaleW = minScale(window.innerWidth, board.width)
    const minScaleH = minScale(window.innerHeight, board.height)

    const newS = getS(s, deltaY, minScaleW, minScaleH)

    setBoardProps({
      s: newS,
      x: coordOnZoom(s, minScaleW, window.innerWidth, board.width, x, clientX, newS),
      y: coordOnZoom(s, minScaleH, window.innerHeight, board.height, y, clientY, newS)
    })
  }

  function move({ clientX, clientY }: React.MouseEvent) {
    const wasStill = Moving.isStill(moveRef.current)

    moveRef.current = {
      h: clientX <= moveDetect ? -1 : window.innerWidth - moveDetect <= clientX ? 1 : 0,
      v: clientY <= moveDetect ? -1 : window.innerHeight - moveDetect <= clientY ? 1 : 0
    }

    if (wasStill && !Moving.isStill(moveRef.current)) loopMove()
  }

  function resetMove() {
    moveRef.current = { h: 0, v: 0 }
  }

  function loopMove() {
    const { s, x, y } = boardPropsRef.current
    const { h, v } = moveRef.current

    const minScaleW = minScale(window.innerWidth, board.width)
    const minScaleH = minScale(window.innerHeight, board.height)

    setBoardProps({
      x: coordOnLoop(minScaleW, window.innerWidth, board.width, x, h, s),
      y: coordOnLoop(minScaleH, window.innerHeight, board.height, y, v, s)
    })

    if (!Moving.isStill(moveRef.current)) setTimeout(loopMove, moveStepMs)
  }

  function setBoardProps(props: Partial<BoardProps>) {
    boardPropsRef.current = { ...boardPropsRef.current, ...props }
    set(props)
  }
}

function getS(oldS: number, deltaY: number, minScaleW: number, minScaleH: number) {
  const minScale = Math.min(minScaleW, minScaleH)
  const scale = oldS + deltaY * -0.03
  return scale < minScale ? minScale : maxScale < scale ? maxScale : scale
}

function coordOnZoom(
  oldS: number,
  minScale: number,
  windowSize: number,
  boardSize: number,
  prevCoord: number,
  clientPos: number,
  newS: number
): number {
  return coord(minScale, windowSize, boardSize, newS, () => {
    const ratio = newS / oldS
    return bounded(
      minCoord(windowSize, boardSize, newS),
      0
    )((1 - ratio) * clientPos + ratio * prevCoord)
  })
}

function coordOnLoop(
  minScale: number,
  windowSize: number,
  boardSize: number,
  prevCoord: number,
  direction: number,
  s: number
): number {
  return coord(minScale, windowSize, boardSize, s, () =>
    bounded(minCoord(windowSize, boardSize, s), 0)(prevCoord - (direction * moveStepPx) / s)
  )
}

function coord(
  minScale: number,
  windowSize: number,
  boardSize: number,
  s: number,
  coordL: Lazy<number>
): number {
  return coordOrMin(minScale, windowSize, boardSize, s)(coordL)
}

function coordOrMin(
  minScale: number,
  windowSize: number,
  boardSize: number,
  s: number
): (coordL: Lazy<number>) => number {
  return coordL => (s < minScale ? minCoord(windowSize, boardSize, s) / 2 : coordL())
}

function minScale(windowSize: number, boardSize: number): number {
  return windowSize / boardSize
}

function minCoord(windowSize: number, boardSize: number, s: number): number {
  return windowSize - boardSize * s
}

function bounded(min: number, max: number): (x: number) => number {
  return x => (x < min ? min : max < x ? max : x)
}

function trans(s: number): string {
  return `scale(${s})`
}

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    overflow: 'hidden',
    position: 'relative',
    backgroundImage: "url('/images/bg.jpg')",
    backgroundSize: '100% 100%'
  }),

  board: (width: number, height: number) =>
    css({
      position: 'absolute',
      width,
      height,
      transformOrigin: 'top left',
      backgroundImage: "url('/images/wood.png')"
    }),

  endTurn: css({
    position: 'absolute',
    right: 0,
    top: 'calc(50vh - 1em)',

    '&:not(.current)': {
      display: 'none'
    }
  })
}
