/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useCallback } from 'react'

import { CombatAndGold } from './playerZone/CombatAndGold'
import { Discard } from './playerZone/Discard'
import { FightZone } from './playerZone/FightZone'
import { Hero } from './playerZone/Hero'
import { PlayerId } from '../../models/PlayerId'
import { Game } from '../../models/game/Game'
import { Referentials } from '../../models/game/Referentials'
import { Referential } from '../../models/game/geometry/Referential'

interface Props {
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, [PlayerId, PartialPlayer]][]
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
  const playerZone = useCallback(
    (ref: Referential, id: PlayerId, player: PartialPlayer): JSX.Element => (
      <div key={PlayerId.unwrap(id)}>
        <FightZone playerRef={ref} current={id === game.current_player} />
        <Discard playerRef={ref} />
        <CombatAndGold playerRef={ref} player={player} />
        <Hero game={game} playerRef={ref} player={[id, player]} />
      </div>
    ),
    [game]
  )

  const [playerId, player] = game.player

  return (
    <div>
      {playerZone(referentials.player, playerId, player)}
      {zippedOtherPlayers.map(([ref, [id, player]]) => playerZone(ref, id, player))}
    </div>
  )
}
