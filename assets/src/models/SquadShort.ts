import * as D from 'io-ts/Decoder'

import { SquadId } from './SquadId'
import { Stage } from './Stage'

export namespace SquadShort {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    id: SquadId.codec,
    stage: Stage.codec,
    n_players: D.number
    /* eslint-enable @typescript-eslint/camelcase */
  })
}

export type SquadShort = D.TypeOf<typeof SquadShort.codec>
