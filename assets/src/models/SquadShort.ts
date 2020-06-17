import * as D from 'io-ts/lib/Decoder'

import { Stage } from './Stage'
import { SquadId } from './SquadId'

export namespace SquadShort {
  export const codec = D.type({
    /* eslint-disable @typescript-eslint/camelcase */
    id: SquadId.codec as D.Decoder<SquadId>,
    stage: Stage.codec,
    n_players: D.number
    /* eslint-enable @typescript-eslint/camelcase */
  })
}

export type SquadShort = D.TypeOf<typeof SquadShort.codec>
