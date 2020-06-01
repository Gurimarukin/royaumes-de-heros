import * as t from 'io-ts'
import { failure } from 'io-ts/lib/PathReporter'
import { Socket, Channel } from 'phoenix'
import { useMemo, useEffect, useCallback } from 'react'

import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { Either, pipe, flow } from '../utils/fp'

interface Listeners {
  readonly onJoinSuccess: (resp: unknown) => void
  readonly onJoinError: (resp: unknown) => void
  readonly onUpdate: (resp: unknown) => void
}

export function useChannel(
  userToken: string,
  topic: string,
  { onJoinSuccess, onJoinError, onUpdate }: Partial<Listeners>
): [Socket, Channel] {
  const [socket, channel] = useMemo<[Socket, Channel]>(() => {
    const socket = new Socket('/socket', { params: { token: userToken } })
    const channel = socket.channel(topic)
    return [socket, channel]
  }, [])

  useEffect(() => {
    socket.connect()

    const join = channel.join()
    if (onJoinSuccess !== undefined) join.receive('ok', onJoinSuccess)
    if (onJoinError !== undefined) join.receive('error', onJoinError)

    if (onUpdate !== undefined) channel.on('update', onUpdate)

    return () => {
      channel.leave()
    }
  }, [])

  return [socket, channel]
}
