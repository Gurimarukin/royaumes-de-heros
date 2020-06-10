/** @jsx jsx */
import { jsx, css, SerializedStyles } from '@emotion/core'
import { Lazy } from 'fp-ts/lib/function'
import { FunctionComponent, useRef, useMemo, useCallback } from 'react'
import { useSpring, animated as a } from 'react-spring'

import { Board } from './Board'
import { GameStyled } from './GameStyled'
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

interface BoardProps {
  readonly s: number
  readonly x: number
  readonly y: number
}

const maxScale = 1

export const BoardNavigation: FunctionComponent<Props> = ({
  call,
  game,
  referentials,
  zippedOtherPlayers,
  showDiscard,
  children
}) => {
  const board = useMemo(
    () => ({ width: params.board.width(referentials), height: params.board.height }),
    [referentials]
  )

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

  const setBoardProps = useCallback(
    (props: Partial<BoardProps>) => {
      boardPropsRef.current = { ...boardPropsRef.current, ...props }
      set(props)
    },
    [set]
  )

  const onWheel = useCallback(
    ({ deltaY, clientX, clientY }: React.WheelEvent) => {
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
    },
    [board.height, board.width, setBoardProps]
  )

  return (
    <GameStyled onWheel={onWheel}>
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
      {children}
    </GameStyled>
  )
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
