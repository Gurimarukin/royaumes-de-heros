/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Chat } from './Chat'
import { ButtonUnderline } from '../Buttons'
import { Game } from '../../models/game/Game'

interface Props {
  readonly game: Game
  readonly endTurnSent: boolean
  readonly endTurn: React.MouseEventHandler<HTMLButtonElement>
  readonly events: [number, string][]
}

export const RightBar: FunctionComponent<Props> = ({ game, endTurnSent, endTurn, events }) => (
  <div>
    <div>
      <ButtonUnderline
        disabled={endTurnSent}
        onClick={endTurn}
        className={Game.isCurrentPlayer(game) ? 'current' : undefined}
      >
        Fin du tour
      </ButtonUnderline>
    </div>
    <div>Card detail</div>
    <Chat lines={events} />
  </div>
)
