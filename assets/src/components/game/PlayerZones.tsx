/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent } from 'react'

import { CombatAndGold } from './playerZone/CombatAndGold'
import { Discard } from './playerZone/Discard'
import { FightZone } from './playerZone/FightZone'
import { Hero } from './playerZone/Hero'
import { WithId } from '../../models/WithId'
import { Game } from '../../models/game/Game'
import { Referentials } from '../../models/game/Referentials'
import { Referential } from '../../models/game/geometry/Referential'

interface Props {
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, WithId<PartialPlayer>][]
}

export interface PartialPlayer {
  readonly name: string
  readonly hp: number
  readonly max_hp: number
  readonly combat: number
  readonly gold: number
}

export const PlayerZones: FunctionComponent<Props> = ({
  game,
  referentials,
  zippedOtherPlayers
}) => {
  const [playerId, player] = game.player
  return (
    <div>
      {referential(referentials.player, playerId, player)}
      {zippedOtherPlayers.map(([ref, [id, player]]) => referential(ref, id, player))}
    </div>
  )

  function referential(ref: Referential, playerId: string, player: PartialPlayer): JSX.Element {
    return (
      <div key={playerId}>
        <FightZone playerRef={ref} current={playerId === game.current_player} />
        <Discard playerRef={ref} />
        <CombatAndGold playerRef={ref} player={player} />
        <Hero playerRef={ref} player={player} />
      </div>
    )
  }
}
