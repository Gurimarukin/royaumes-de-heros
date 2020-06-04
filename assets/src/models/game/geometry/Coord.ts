import { params } from '../../../params'

export type Coord = [number, number]

export namespace Coord {
  export function playerZone([col, row]: [number, number]): Coord {
    return [
      params.market.width +
        2 * params.card.margin +
        col * (params.playerZone.width + params.card.margin),
      row * (params.playerZone.height + params.card.margin)
    ]
  }
}
