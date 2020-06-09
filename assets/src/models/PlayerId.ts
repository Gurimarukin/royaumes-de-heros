import * as t from 'io-ts'
import { Codec } from 'io-ts/lib/Codec'
import { fromNewtype } from 'io-ts-types/lib/fromNewtype'
import { Newtype, iso } from 'newtype-ts'

export type PlayerId = Newtype<{ readonly PlayerId: unique symbol }, string>

const isoPlayerId = iso<PlayerId>()

export namespace PlayerId {
  export const wrap = isoPlayerId.wrap
  export const unwrap = isoPlayerId.unwrap
  export const codec = fromNewtype<PlayerId>(t.string) as Codec<string, PlayerId>
}
