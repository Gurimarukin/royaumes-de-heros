/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { Lazy } from 'fp-ts/lib/function'
import React, { FunctionComponent, useRef } from 'react'
import { useSpring, animated as a } from 'react-spring'

import { Game } from '../../models/game/Game'

interface Props {
  readonly call: (msg: any) => void
  readonly state: Game
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

const maxScale = 1.5

const moveDetect = 40
const moveStepPx = 300
const moveStepMs = 100

export const GameComponent: FunctionComponent<Props> = ({ call, state }) => {
  const boardPropsRef = useRef<BoardProps>({ s: 1, x: 0, y: window.innerHeight - board.height })
  const [props, set] = useSpring(() => ({ s: 1, x: 0, y: window.innerHeight - board.height }))

  const moveRef = useRef<Moving>({ h: 0, v: 0 })

  return (
    <div css={styles.container} onWheel={onWheel} onMouseMove={move} onMouseLeave={resetMove}>
      <a.div
        css={styles.board}
        style={{ transform: props.s.interpolate(trans), left: props.x, top: props.y }}
      />
      {/* <pre css={stylesPre}>{JSON.stringify(state, null, 2)}</pre> */}
      {/* <button onClick={play}>Jouer</button> */}
    </div>
  )

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
  return coordOrMin(
    minScale,
    windowSize,
    boardSize,
    newS
  )(() => {
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
  return coordOrMin(
    minScale,
    windowSize,
    boardSize,
    s
  )(() => bounded(minCoord(windowSize, boardSize, s), 0)(prevCoord - direction * moveStepPx * s))
}

function coordOrMin(
  minScale: number,
  windowSize: number,
  boardSize: number,
  s: number
): (coord: Lazy<number>) => number {
  return coord => (s < minScale ? minCoord(windowSize, boardSize, s) / 2 : coord())
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

const board = {
  width: 1920 * 3,
  height: 1080 * 3
}

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    overflow: 'hidden',
    position: 'relative'
  }),

  board: css({
    position: 'absolute',
    width: board.width,
    height: board.height,
    transformOrigin: 'top left',
    backgroundImage: 'radial-gradient(red,orange,yellow,green,blue,indigo,violet)'
  })
}

const stylesPre = css({
  position: 'absolute',
  top: 0
})
