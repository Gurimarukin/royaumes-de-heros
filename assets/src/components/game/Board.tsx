/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, Fragment } from 'react'

import { Cards } from './Cards'
import { MarketZone } from './MarketZone'
import { Overlay } from './Overlay'
import { PlayerZones } from './PlayerZones'
import { PlayerId } from '../../models/PlayerId'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Referential } from '../../models/game/geometry/Referential'

interface Props {
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, [PlayerId, OtherPlayer]][]
  readonly showDiscard: (playerId: PlayerId) => void
}

export const Board: FunctionComponent<Props> = ({
  game,
  referentials,
  zippedOtherPlayers,
  showDiscard
}) => (
  <Fragment>
    <MarketZone />
    <PlayerZones game={game} referentials={referentials} zippedOtherPlayers={zippedOtherPlayers} />
    <Cards
      showDiscard={showDiscard}
      game={game}
      referentials={referentials}
      zippedOtherPlayers={zippedOtherPlayers}
    />
    <Overlay game={game} referentials={referentials} zippedOtherPlayers={zippedOtherPlayers} />
  </Fragment>
)
