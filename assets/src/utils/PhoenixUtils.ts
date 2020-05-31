import * as t from 'io-ts'
import { failure } from 'io-ts/lib/PathReporter'
import { Push, Socket, Channel } from 'phoenix'

import { Future, pipe, Either } from './fp'

export namespace PhoenixUtils {
  export function toFuture(push: Push): Future<any> {
    return Future.apply(
      () => new Promise((resolve, reject) => push.receive('ok', resolve).receive('error', reject))
    )
  }

  export function initSocket<A>(
    onStateReceived: (a: A) => void,
    codec: t.Type<A>
  ): [Socket, Channel] {
    /*{ params: { token: window.userToken } }*/
    const socket = new Socket('/socket')
    socket.connect()

    const channel = socket.channel('squads')

    channel
      .join()
      .receive('ok', decodePayload)
      .receive('error', resp => console.error('error:', resp))

    channel.on('update', decodePayload)

    return [socket, channel]

    function decodePayload(resp: unknown): void {
      pipe(
        resp,
        t.strict({ body: codec }).decode,
        Either.fold(
          e => console.error("couldn't decode response:", failure(e)),
          ({ body }) => {
            console.log('new state:', body)
            onStateReceived(body)
          }
        )
      )
    }
  }
}
