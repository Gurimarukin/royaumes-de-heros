import * as D from 'io-ts/Decoder'

export namespace ChannelError {
  export const codec = D.type({
    status: D.number
  })
}

export type ChannelError = D.TypeOf<typeof ChannelError.codec>
