/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import React, { FunctionComponent, useCallback, useRef } from 'react'
import { useSpring, animated as a } from 'react-spring'

import { Game } from '../../models/game/Game'

interface Props {
  readonly call: (msg: any) => void
  readonly state: Game
}

interface Pos {
  readonly s: number
  readonly x: number
  readonly y: number
}

const maxScale = 1.5

export const GameComponent: FunctionComponent<Props> = ({ call, state }) => {
  const posRef = useRef<Pos>({ s: 1, x: 0, y: window.innerHeight - board.height })
  const [props, set] = useSpring(() => ({ s: 1, x: 0, y: window.innerHeight - board.height }))

  // ({ deltaY }: React.WheelEvent) => setScale(scale.current + deltaY / (-50 * scale.current)),

  return (
    <div css={styles.container} onWheel={onWheel}>
      <a.div
        css={styles.board}
        style={{
          transform: props.s.interpolate(trans),
          left: props.x,
          top: props.y
        }}
      />
      <pre css={stylesPre}>{JSON.stringify(state, null, 2)}</pre>
      {/* <button onClick={play}>Jouer</button> */}
    </div>
  )

  function onWheel({ deltaY, clientX, clientY }: React.WheelEvent) {
    const zoomIn = deltaY < 0
    const minScaleW = window.innerWidth / board.width
    const minScaleH = window.innerHeight / board.height

    const s = getS()
    const getX = getCoord(window.innerWidth, board.width, posRef.current.x, clientX)
    const getY = getCoord(window.innerHeight, board.height, posRef.current.y, clientY)

    posRef.current = {
      s,
      x: s < minScaleW ? (window.innerWidth - board.width * s) / 2 : getX(s),
      y: s < minScaleH ? (window.innerHeight - board.height * s) / 2 : getY(s)
    }
    set(posRef.current)

    function getS() {
      const minScale = Math.min(minScaleW, minScaleH)
      const scale = posRef.current.s + deltaY * -0.03
      return scale < minScale ? minScale : maxScale < scale ? maxScale : scale
    }

    function getCoord(
      windowSize: number,
      boardSize: number,
      prevCoord: number,
      clientPos: number
    ): (s: number) => number {
      return s => {
        const min = windowSize - boardSize * s

        const ratio = s / posRef.current.s
        const X = zoomIn ? clientPos : windowSize / 2

        return bounded(min, 0)((1 - ratio) * X + ratio * prevCoord)
      }
    }
  }
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
    // backgroundImage: 'linear-gradient(to bottom right, red,orange,yellow,green,blue,indigo,violet)',
    // border: '1px solid red'
  })
}

const stylesPre = css({
  position: 'absolute',
  top: 0
})
