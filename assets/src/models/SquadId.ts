import * as C from 'io-ts/Codec'
import { Newtype, iso } from 'newtype-ts'

import { fromNewtype } from '../utils/fromNewType'

export type SquadId = Newtype<{ readonly SquadId: unique symbol }, string>

const isoSquadId = iso<SquadId>()

export namespace SquadId {
  export const wrap = isoSquadId.wrap
  export const unwrap = isoSquadId.unwrap
  export const codec = fromNewtype<SquadId>(C.string)
}
