import * as D from 'io-ts/lib/Decoder'

import { PlayerId } from './PlayerId'

export namespace User {
  export const codec = D.type({
    id: PlayerId.codec,
    token: D.string,
    name: D.string
  })

  export const empty: User = { id: PlayerId.wrap(''), token: '', name: '' }
}

export type User = D.TypeOf<typeof User.codec>
