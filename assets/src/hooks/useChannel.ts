import { Socket, Channel } from 'phoenix'
import { useMemo, useEffect } from 'react'

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

    join.receive('ok', r => {
      console.log('r =', r)
      if (onJoinSuccess !== undefined) onJoinSuccess(r)
    })

    join.receive('error', e => {
      console.log('e =', e)
      if (onJoinError !== undefined) onJoinError(e)
    })

    channel.on('update', u => {
      console.log('u =', u)
      if (onUpdate !== undefined) onUpdate(u)
    })

    return () => {
      channel.leave()
    }
  }, [])

  return [socket, channel]
}
