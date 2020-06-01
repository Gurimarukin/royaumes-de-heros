import * as t from 'io-ts'
import { failure } from 'io-ts/lib/PathReporter'
import { Push } from 'phoenix'

import { Future, Either, pipe, flow } from './fp'

export namespace PhoenixUtils {
  export function channelToFuture(push: Push): Future<any> {
    return Future.apply(
      () => new Promise((resolve, reject) => push.receive('ok', resolve).receive('error', reject))
    )
  }

  export function handleResponse<A>(
    decode: (u: unknown) => t.Validation<A>
  ): (onRight: (a: A) => void) => (resp: unknown) => void {
    return onRight => resp => {
      console.log('decoding response:', resp)
      pipe(
        resp,
        decode,
        Either.fold(e => console.error("couldn't decode response:", failure(e)), onRight)
      )
    }
  }

  export function decodeBody<A>(
    decode: (u: unknown) => t.Validation<A>
  ): (resp: unknown) => t.Validation<A> {
    return flow(
      t.strict({ body: t.unknown }).decode,
      Either.chain(({ body }) => decode(body))
    )
  }
}
