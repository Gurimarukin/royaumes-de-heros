import { params } from '../../../params'

export type Coord = [number, number]

export namespace Coord {
  export function playerZone([col, row]: [number, number]): Coord {
    return [params.market.width + col * params.playerZone.width, row * params.playerZone.height]
  }
}
