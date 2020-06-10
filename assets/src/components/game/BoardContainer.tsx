/** @jsx jsx */
import { jsx, css, SerializedStyles } from '@emotion/core'
import { Lazy } from 'fp-ts/lib/function'
import { FunctionComponent, useRef, useMemo, useCallback } from 'react'
import { useSpring, animated as a } from 'react-spring'

import { Board } from './Board'
import { BoardContainerStyled } from './BoardContainerStyled'
import { params } from '../../params'
import { CallChannel } from '../../models/CallMessage'
import { PlayerId } from '../../models/PlayerId'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Referential } from '../../models/game/geometry/Referential'

interface Props {
  readonly call: CallChannel
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

const maxScale = 1

export const BoardContainer: FunctionComponent<Props> = ({
  call,
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
  const [props, set] = useSpring<BoardProps>(() => BoardProps.empty)

  const setBoardProps = useCallback(
    (props: Partial<BoardProps>) => {
      boardPropsRef.current = { ...boardPropsRef.current, ...props }
      set(props)
    },
    [set]
  )

  const updateProps = useCallback(
    (elt: HTMLDivElement | null) => {
      if (elt !== null) setBoardProps(propsFromElt(board, elt))
    },
    [board, setBoardProps]
  )

  const onWheel = useCallback(
    (e: React.WheelEvent) => setBoardProps(propsOnWheel(boardPropsRef.current, board, e)),
    [board, setBoardProps]
  )

  return (
    <BoardContainerStyled ref={updateProps} onWheel={onWheel}>
      <a.div
        css={stylesBoard(board.width, board.height)}
        style={{ transform: props.s.interpolate(trans), left: props.x, top: props.y }}
      >
        <Board
          call={call}
          game={game}
          referentials={referentials}
          zippedOtherPlayers={zippedOtherPlayers}
          showDiscard={showDiscard}
        />
      </a.div>
    </BoardContainerStyled>
  )
}

function propsFromElt(board: BoardSize, elt: HTMLElement): Partial<BoardProps> {
  const clientWidth = elt.clientWidth
  const clientHeight = elt.clientHeight
  const minScaleW = minScale(clientWidth, board.width)
  const minScaleH = minScale(clientHeight, board.height)
  const s = Math.min(minScaleW, minScaleH)
  const x = coord(minScaleW, clientWidth, board.width, s, () => 0)
  const y = coord(minScaleH, clientHeight, board.height, s, () => clientHeight - board.height * s)
  return { s, x, y, clientWidth, clientHeight, minScaleW, minScaleH }
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
