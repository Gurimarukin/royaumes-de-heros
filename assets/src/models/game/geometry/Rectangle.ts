import { Coord } from './Coord'
import { params } from '../../../params'

export interface Rectangle {
  readonly position: Coord
  readonly width: number
  readonly height: number
}

export namespace Rectangle {
  export function card(position: Coord): Rectangle {
    return { position, width: params.card.width, height: params.card.height }
  }
}
