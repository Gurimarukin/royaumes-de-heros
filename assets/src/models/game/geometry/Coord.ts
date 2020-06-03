import { params } from '../../../params'

export type Coord = [number, number]

export namespace Coord {
  export function playerZone([col, row]: [number, number]): Coord {
    return [
      col * params.playerZone.width,
      row * params.playerZone.height + (row === 0 ? 0 : params.market.height)
    ]
  }
}
