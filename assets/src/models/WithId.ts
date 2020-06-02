import * as D from 'io-ts/lib/Decoder'

export type WithId<A> = [string, A]

export namespace WithId {
  export function codec<A>(c: D.Decoder<A>): D.Decoder<WithId<A>> {
    return D.tuple(D.string, c)
  }
}
