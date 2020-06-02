import * as D from 'io-ts/lib/Decoder'
import { Either } from '../utils/fp'

export namespace Unknown {
  export const codec: D.Decoder<unknown> = {
    decode: Either.right
  }
}
