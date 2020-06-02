import { params } from '../../../params'

export type Coord = [number, number]

export namespace Coord {
  export function playerZone(col: number, row: number): Coord {
    return [col * params.playerZone.width, row * params.playerZone.height]
  }
}
