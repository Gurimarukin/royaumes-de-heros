import { Coord } from './Coord'
import { params } from '../../../params'
import { pipe, Maybe, List } from '../../../utils/fp'

export interface Referential {
  readonly position: Coord
  readonly width: number
  readonly height: number
}

export namespace Referential {
  export const self: Referential = playerZone(Coord.playerZone(0, 1))

  export function playerZone(position: Coord): Referential {
    return { position, width: params.playerZone.width, height: params.playerZone.height }
  }

  export function otherPlayers(n: number): Referential[] {
    return pipe(
      referentials[n],
      Maybe.fromNullable,
      Maybe.map(List.map(playerZone)),
      Maybe.getOrElse<Referential[]>(() => [])
    )
  }

  export function coord([x2, y2]: Coord): (ref: Referential) => Coord {
    return ({ position: [x1, y1] }) => [x1 + x2, y1 + y2]
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
