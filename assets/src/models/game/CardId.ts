import * as t from 'io-ts'
import { Codec } from 'io-ts/lib/Codec'
import { fromNewtype } from 'io-ts-types/lib/fromNewtype'
import { Newtype, iso } from 'newtype-ts'

export type CardId = Newtype<{ readonly CardId: unique symbol }, string>

const isoCardId = iso<CardId>()

export namespace CardId {
  export const wrap = isoCardId.wrap
  export const unwrap = isoCardId.unwrap
  export const codec = fromNewtype<CardId>(t.string) as Codec<string, CardId>
}
