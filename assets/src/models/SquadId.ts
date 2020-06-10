import * as t from 'io-ts'
import { fromNewtype } from 'io-ts-types/lib/fromNewtype'
import { Newtype, iso } from 'newtype-ts'

export type SquadId = Newtype<{ readonly SquadId: unique symbol }, string>

const isoSquadId = iso<SquadId>()

export namespace SquadId {
  export const wrap = isoSquadId.wrap
  export const unwrap = isoSquadId.unwrap
  export const codec = fromNewtype<SquadId>(t.string)
}
