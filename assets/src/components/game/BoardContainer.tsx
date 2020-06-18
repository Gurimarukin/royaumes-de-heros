/** @jsx jsx */
import { jsx, css, SerializedStyles } from '@emotion/core'
import { Lazy } from 'fp-ts/lib/function'
import { FunctionComponent, useRef, useMemo, useCallback } from 'react'
import { useSpring, animated as a } from 'react-spring'

import { Board } from './Board'
import { BoardContainerStyled } from './BoardContainerStyled'
import { params } from '../../params'
import { PlayerId } from '../../models/PlayerId'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Referential } from '../../models/game/geometry/Referential'
import { useWindowEvent } from '../../hooks/useWindowEvent'
import { Maybe, pipe, flow, List } from '../../utils/fp'

interface Props {
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, [PlayerId, OtherPlayer]][]
  readonly showDiscard: (playerId: PlayerId) => void
}

interface BoardSize {
  readonly width: number
  readonly height: number
}

interface BoardProps {
  readonly s: number
  readonly x: number
  readonly y: number
  readonly clientWidth: number
  readonly clientHeight: number
  readonly minScaleW: number
  readonly minScaleH: number
}

namespace BoardProps {
  export const empty: BoardProps = {
    s: 0,
    x: 0,
    y: 0,
    clientWidth: 0,
    clientHeight: 0,
    minScaleW: 0,
    minScaleH: 0
  }
}

type Arrow = 'ArrowLeft' | 'ArrowRight' | 'ArrowUp' | 'ArrowDown'

namespace Arrow {
  export const values: Arrow[] = ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown']

  export function isArrow(key: string): key is Arrow {
    return pipe(
      values,
      List.exists(_ => _ === key)
    )
  }
}

type Moving = Readonly<Record<Arrow, boolean>>

namespace Moving {
  export const empty: Moving = {
    ArrowLeft: false,
    ArrowRight: false,
    ArrowUp: false,
    ArrowDown: false
  }

  export function update(key: Arrow, value: boolean): (prev: Moving) => Moving {
    return prev => ({ ...prev, [key]: value })
  }

  export function toDirection(moving: Moving): Readonly<{ h: -1 | 0 | 1; v: -1 | 0 | 1 }> {
    return {
      h: dir(moving.ArrowLeft, moving.ArrowRight),
      v: dir(moving.ArrowUp, moving.ArrowDown)
    }
  }

  function dir(a: boolean, b: boolean): -1 | 0 | 1 {
    return a !== b ? (a ? -1 : 1) : 0
  }
}

const maxScale = 1
const moveStepPx = 100

export const BoardContainer: FunctionComponent<Props> = ({
  game,
  referentials,
  zippedOtherPlayers,
  showDiscard
}) => {
  const board = useMemo<BoardSize>(
    () => ({ width: params.board.width(referentials), height: params.board.height }),
    [referentials]
  )

  const boardPropsRef = useRef<BoardProps>(BoardProps.empty)
  const [props, set] = useSpring<BoardProps>(() => ({
    ...BoardProps.empty,
    config: { clamp: true }
  }))

  const setBoardProps = useCallback(
    (props: Partial<BoardProps>) => {
      boardPropsRef.current = { ...boardPropsRef.current, ...props }
      set(props)
    },
    [set]
  )

  const updateProps = useCallback(
    () => pipe(containerRef.current, Maybe.map(flow(propsFromElt(board), setBoardProps))),
    [board, setBoardProps]
  )

  const containerRef = useRef<Maybe<HTMLDivElement>>(Maybe.none)
  const setContainerRef = useCallback(
    (elt: HTMLDivElement | null) => {
      const res = Maybe.fromNullable(elt)
      containerRef.current = res
      updateProps()
    },
    [updateProps]
  )
  useWindowEvent('resize', updateProps)

  const onWheel = useCallback(
    (e: React.WheelEvent) => setBoardProps(propsOnWheel(boardPropsRef.current, board, e)),
    [board, setBoardProps]
  )

  const movingRef = useRef<Moving>(Moving.empty)
  useWindowEvent('keydown', (e: KeyboardEvent) => {
    if (Arrow.isArrow(e.key)) {
      movingRef.current = pipe(movingRef.current, Moving.update(e.key, true))

      const { s, x, y, clientWidth, clientHeight, minScaleW, minScaleH } = boardPropsRef.current
      const { h, v } = Moving.toDirection(movingRef.current)

      setBoardProps({
        x: coordOnArrow(minScaleW, clientWidth, board.width, x, h, s),
        y: coordOnArrow(minScaleH, clientHeight, board.height, y, v, s)
      })
    }
  })
  useWindowEvent('keyup', (e: KeyboardEvent) => {
    if (Arrow.isArrow(e.key)) {
      movingRef.current = pipe(movingRef.current, Moving.update(e.key, false))
    }
  })

  return (
    <BoardContainerStyled ref={setContainerRef} onWheel={onWheel}>
      <a.div
        css={stylesBoard(board.width, board.height)}
        style={{ transform: props.s.interpolate(trans), left: props.x, top: props.y }}
      >
        <Board
          game={game}
          referentials={referentials}
          zippedOtherPlayers={zippedOtherPlayers}
          showDiscard={showDiscard}
        />
      </a.div>
    </BoardContainerStyled>
  )
}

function propsFromElt(board: BoardSize): (elt: HTMLElement) => Partial<BoardProps> {
  return elt => {
    const clientWidth = elt.clientWidth
    const clientHeight = elt.clientHeight
    const minScaleW = minScale(clientWidth, board.width)
    const minScaleH = minScale(clientHeight, board.height)
    const s = Math.min(minScaleW, minScaleH)
    const x = coord(minScaleW, clientWidth, board.width, s, () => 0)
    const y = coord(minScaleH, clientHeight, board.height, s, () => clientHeight - board.height * s)
    return { s, x, y, clientWidth, clientHeight, minScaleW, minScaleH }
  }
}

function propsOnWheel(
  previous: BoardProps,
  board: BoardSize,
  { deltaY, clientX, clientY }: React.WheelEvent
): Partial<BoardProps> {
  const { s, x, y, clientWidth, clientHeight, minScaleW, minScaleH } = previous

  const minScale = Math.min(minScaleW, minScaleH)
  const scale = s + deltaY * -0.03
  const newS = scale < minScale ? minScale : maxScale < scale ? maxScale : scale

  return {
    s: newS,
    x: coordOnZoom(s, minScaleW, clientWidth, board.width, x, clientX, newS),
    y: coordOnZoom(s, minScaleH, clientHeight, board.height, y, clientY, newS)
  }
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

function coordOnArrow(
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

function stylesBoard(width: number, height: number): SerializedStyles {
  return css({
    position: 'absolute',
    width,
    height,
    transformOrigin: 'top left',
    backgroundImage: "url('/images/wood.png')"
  })
}
