import { Referential } from './geometry/Referential'

export interface Referentials {
  readonly market: Referential
  readonly player: Referential
  readonly others: Referential[]
}
