import * as C from 'io-ts/Codec'
import { Newtype, iso } from 'newtype-ts'

import { fromNewtype } from '../../utils/fromNewType'

export type CardId = Newtype<{ readonly CardId: unique symbol }, string>

const isoCardId = iso<CardId>()

export namespace CardId {
  export const wrap = isoCardId.wrap
  export const unwrap = isoCardId.unwrap
  export const codec = fromNewtype<CardId>(C.string)
}
