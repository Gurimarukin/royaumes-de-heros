import { lookup } from 'fp-ts/lib/Record'

import { Coord } from './Coord'
import { Rectangle } from './Rectangle'
import { params } from '../../../params'
import { pipe, Maybe, List } from '../../../utils/fp'

export interface Referential {
  readonly position: Coord
  readonly width: number
  readonly height: number
  readonly inverted: boolean
}

export namespace Referential {
  export const market: Referential = {
    position: [0, 0],
    width: params.market.width,
    height: params.market.height,
    inverted: false
  }

  export const self: Referential = playerZone([0, 1])

  export function playerZone(position: Coord): Referential {
    return {
      position: Coord.playerZone(position),
      width: params.playerZone.width,
      height: params.playerZone.height,
      inverted: position[1] === 0 // invert first row
    }
  }

  export function otherPlayers(n: number): Referential[] {
    return pipe(
      lookup(String(n), referentials),
      Maybe.map(List.map(playerZone)),
      Maybe.getOrElse<Referential[]>(() => [])
    )
  }

  export const fightZone: Referential = {
    position: [0, 0],
    width: params.fightZone.width,
    height: params.fightZone.height,
    inverted: false
  }

  export function coord({
    position: [x2, y2],
    width: rectWidth,
    height: rectHeight
  }: Rectangle): (ref: Referential) => Coord {
    return ({ position: [x1, y1], width, height, inverted }) => [
      inverted ? x1 + (width - x2) - rectWidth : x1 + x2,
      inverted ? y1 + (height - y2) - rectHeight : y1 + y2
    ]
  }

  export function combine(other: Referential): (ref: Referential) => Referential {
    return ref => ({
      position: coord(other)(ref),
      width: other.width,
      height: other.height,
      inverted: other.inverted !== ref.inverted
    })
  }
}

const referentials: Record<number, Coord[]> = {
  1: [[0, 0]],
  2: [
    [0, 0],
    [1, 0]
  ],
  3: [
    [0, 0],
    [1, 0],
    [1, 1]
  ],
  4: [
    [0, 0],
    [1, 0],
    [2, 0],
    [1, 1]
  ],
  5: [
    [0, 0],
    [1, 0],
    [2, 0],
    [2, 1],
    [1, 1]
  ]
}
