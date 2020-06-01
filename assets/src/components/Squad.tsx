/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext } from 'react'

import { UserContext } from '../contexts/UserContext'
import { useChannel } from '../hooks/useChannel'
import { AsyncState } from '../models/AsyncState'
import { ChannelError } from '../models/ChannelError'
import { SquadState } from '../models/SquadState'
import { pipe } from '../utils/fp'

interface Props {
  readonly id: string
}

export const Squad: FunctionComponent<Props> = ({ id }) => {
  const user = useContext(UserContext)

  const [state, setState] = useState<AsyncState<ChannelError, SquadState>>(AsyncState.Loading)
  const [, channel] = useChannel(user.token, `squad:${id}`, setState, SquadState.codec.decode)

  return (
    <div>
      <div>{user.name}</div>
      {pipe(state, AsyncState.fold({ onLoading, onError, onSuccess }))}
    </div>
  )

  function onLoading() {
    return <div>Loading...</div>
  }

  function onError(error: ChannelError) {
    return <pre>Error: {JSON.stringify(error)}</pre>
  }

  function onSuccess(state: SquadState) {
    return <pre>{JSON.stringify(state, null, 2)}</pre>
  }
}
