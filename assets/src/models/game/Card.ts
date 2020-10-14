import * as D from 'io-ts/Decoder'

export namespace Card {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    key: D.string,
    expend_ability_used: D.boolean,
    ally_ability_used: D.boolean
    /* eslint-enable @typescript-eslint/camelcase */
  })

  export function reset(card: Card): Card {
    return fromKey(card.key)
  }

  export function fromKey(key: string): Card {
    // eslint-disable-next-line @typescript-eslint/camelcase
    return { key, expend_ability_used: false, ally_ability_used: false }
  }
}

export type Card = D.TypeOf<typeof Card.codec>
