import * as t from 'io-ts'

export namespace ChannelError {
  export const codec = t.strict({
    status: t.number
  })
}

export type ChannelError = t.TypeOf<typeof ChannelError.codec>
