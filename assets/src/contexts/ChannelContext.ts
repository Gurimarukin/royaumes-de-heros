import { createContext } from 'react'

import { CallMessage } from '../models/CallMessage'
import { Future, Either } from '../utils/fp'

interface Context {
  readonly call: (msg: CallMessage) => Future<Either<unknown, unknown>>
  readonly leave: () => Future<Either<unknown, unknown>>
}

export const ChannelContext = createContext<Context>({
  call: () => Future.right(Either.right(undefined)),
  leave: () => Future.right(Either.right(undefined))
})
