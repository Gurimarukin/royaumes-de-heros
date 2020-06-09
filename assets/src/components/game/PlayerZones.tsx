/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent } from 'react'

import { CombatAndGold } from './playerZone/CombatAndGold'
import { Discard } from './playerZone/Discard'
import { FightZone } from './playerZone/FightZone'
import { Hero } from './playerZone/Hero'
import { CallChannel, CallMessage } from '../../models/CallMessage'
import { PlayerId } from '../../models/PlayerId'
import { Game } from '../../models/game/Game'
import { Referentials } from '../../models/game/Referentials'
import { Referential } from '../../models/game/geometry/Referential'

interface Props {
  readonly call: CallChannel
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
  call,
  game,
  referentials,
  zippedOtherPlayers
}) => {
  const [playerId, player] = game.player
  return (
    <div>
      {playerZone(referentials.player, playerId, player)}
      {zippedOtherPlayers.map(([ref, [id, player]]) => playerZone(ref, id, player))}
    </div>
  )

  function playerZone(ref: Referential, id: PlayerId, player: PartialPlayer): JSX.Element {
    return (
      <div key={PlayerId.unwrap(id)}>
        <FightZone playerRef={ref} current={id === game.current_player} />
        <Discard playerRef={ref} />
        <CombatAndGold playerRef={ref} player={player} />
        <Hero call={call} game={game} playerRef={ref} player={[id, player]} />
      </div>
    )
  }
}
