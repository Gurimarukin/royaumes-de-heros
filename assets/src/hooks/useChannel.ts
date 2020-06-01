import * as t from 'io-ts'
import { failure } from 'io-ts/lib/PathReporter'
import { Socket, Channel } from 'phoenix'
import { useMemo, useEffect, useCallback } from 'react'

import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { Either, pipe, flow } from '../utils/fp'

export function useChannel<A>(
  userToken: string,
  topic: string,
  setState: (state: AsyncState<ChannelError, A>) => void,
  decode: (u: unknown) => t.Validation<A>
): [Socket, Channel] {
  const [socket, channel] = useMemo<[Socket, Channel]>(() => {
    const socket = new Socket('/socket', { params: { token: userToken } })
    const channel = socket.channel(topic)
    return [socket, channel]
  }, [])

  const handleSuccess = useCallback(
    handleResponse(
      flow(
        t.strict({ body: t.unknown }).decode,
        Either.chain(({ body }) => decode(body))
      )
    )(state => {
      console.log('new state:', state)
      pipe(state, AsyncState.Success, setState)
    }),
    []
  )

  const handleError = useCallback(
    handleResponse(ChannelError.codec.decode)(error => {
      if (error.status === 403 || error.status === 404) {
        channel.leave()
      }
      pipe(error, AsyncState.Error, setState)
    }),
    []
  )

  useEffect(() => {
    socket.connect()

    channel.join().receive('ok', handleSuccess).receive('error', handleError)

    channel.on('update', handleSuccess)

    return () => {
      channel.leave()
    }
  }, [])

  return [socket, channel]
}

function handleResponse<A>(
  decode: (u: unknown) => t.Validation<A>
): (onRight: (a: A) => void) => (resp: string) => void {
  return onRight => resp => {
    console.log('decoding response:', resp)
    pipe(
      resp,
      decode,
      Either.fold(e => console.error("couldn't decode response:", failure(e)), onRight)
    )
  }
}
