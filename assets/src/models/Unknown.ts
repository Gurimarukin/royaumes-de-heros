import * as D from 'io-ts/Decoder'

import { Either } from '../utils/fp'

export namespace Unknown {
  export const codec: D.Decoder<unknown, unknown> = {
    decode: Either.right
  }
}
