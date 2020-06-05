import * as D from 'io-ts/lib/Decoder'

export namespace Card {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    key: D.string,
    expend_ability_used: D.boolean,
    ally_ability_used: D.boolean
    /* eslint-enable @typescript-eslint/camelcase */
  })
}

export type Card = D.TypeOf<typeof Card.codec>
