import { Coord } from './Coord'
import { params } from '../../../params'

export interface Rectangle {
  readonly position: Coord
  readonly width: number
  readonly height: number
}

export function Rectangle(position: Coord, width: number, height: number): Rectangle {
  return { position, width, height }
}

export namespace Rectangle {
  export function market(position: Coord): Rectangle {
    return { position, width: params.market.width, height: params.market.height }
  }

  export function fightZone(position: Coord): Rectangle {
    return { position, width: params.fightZone.width, height: params.fightZone.height }
  }

  export function card(position: Coord): Rectangle {
    return { position, width: params.card.width, height: params.card.height }
  }
}
