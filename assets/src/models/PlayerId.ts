import * as C from 'io-ts/Codec'
import { Newtype, iso } from 'newtype-ts'

import { fromNewtype } from '../utils/fromNewType'

export type PlayerId = Newtype<{ readonly PlayerId: unique symbol }, string>

const isoPlayerId = iso<PlayerId>()

export namespace PlayerId {
  export const wrap = isoPlayerId.wrap
  export const unwrap = isoPlayerId.unwrap
  export const codec = fromNewtype<PlayerId>(C.string)
}
