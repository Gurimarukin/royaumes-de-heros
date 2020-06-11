/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, Fragment } from 'react'

import { Cards } from './Cards'
import { MarketZone } from './MarketZone'
import { PlayerZones } from './PlayerZones'
import { CallChannel } from '../../models/CallMessage'
import { PlayerId } from '../../models/PlayerId'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Referential } from '../../models/game/geometry/Referential'

interface Props {
  readonly call: CallChannel
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, [PlayerId, OtherPlayer]][]
  readonly showDiscard: (playerId: PlayerId) => void
  readonly showCardDetail: (key: string) => void
}

export const Board: FunctionComponent<Props> = ({
  call,
  game,
  referentials,
  zippedOtherPlayers,
  showDiscard,
  showCardDetail
}) => (
  <Fragment>
    <MarketZone />
    <PlayerZones
      call={call}
      game={game}
      referentials={referentials}
      zippedOtherPlayers={zippedOtherPlayers}
    />
    <Cards
      call={call}
      showDiscard={showDiscard}
      showCardDetail={showCardDetail}
      game={game}
      referentials={referentials}
      zippedOtherPlayers={zippedOtherPlayers}
    />
  </Fragment>
)
