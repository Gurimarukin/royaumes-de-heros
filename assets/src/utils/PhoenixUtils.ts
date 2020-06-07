import * as D from 'io-ts/lib/Decoder'
import { Lazy } from 'fp-ts/lib/function'
import { draw } from 'io-ts/lib/Tree'
import { Push } from 'phoenix'

import { Future, Either, pipe, flow } from './fp'
import { Unknown } from '../models/Unknown'

export namespace PhoenixUtils {
  export function pushToFuture(push: Lazy<Push>): Future<Either<unknown, unknown>> {
    return Future.apply(
      () =>
        new Promise<Either<unknown, unknown>>(resolve => {
          push()
            .receive('ok', flow(Either.right, resolve))
            .receive('error', flow(Either.left, resolve))
        })
    )
  }

  export function handleResponse<A>(
    decode: (u: unknown) => Either<D.DecodeError, A>
  ): (onRight: (a: A) => void) => (resp: unknown) => void {
    return onRight => resp => {
      console.log('decoding response:', resp)
      pipe(
        resp,
        decode,
        Either.fold(e => {
          // console.error("couldn't decode response:", draw(e))
        }, onRight)
      )
    }
  }

  export function decodeBody<A>(
    decode: (u: unknown) => Either<D.DecodeError, A>
  ): (resp: unknown) => Either<D.DecodeError, A> {
    return flow(
      D.type({ body: Unknown.codec }).decode,
      Either.chain(({ body }) => decode(body))
    )
  }
}
