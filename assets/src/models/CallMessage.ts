import { PlayerId } from './PlayerId'
import { Ability } from './game/Ability'
import { CardId } from './game/CardId'
import { Interaction } from './game/Interaction'
import { Future, Either } from '../utils/fp'

export type CallChannel = (msg: CallMessage) => Future<Either<unknown, unknown>>

export type CallMessage =
  | CallMessage.Attack
  | CallMessage.BuyCard
  | CallMessage.DiscardPhase
  | CallMessage.DrawPhase
  | CallMessage.Interact
  | CallMessage.PlayCard
  | CallMessage.StartGame
  | CallMessage.UseAbility

export namespace CallMessage {
  export type Attack = ['attack', PlayerId, '__player' | CardId]
  export function Attack(playerId: PlayerId, cardId: '__player' | CardId): Attack {
    return ['attack', playerId, cardId]
  }

  export type BuyCard = ['buy_card', CardId]
  export function BuyCard(cardId: CardId): BuyCard {
    return ['buy_card', cardId]
  }

  export type DiscardPhase = 'discard_phase'
  export const DiscardPhase: DiscardPhase = 'discard_phase'

  export type DrawPhase = 'draw_phase'
  export const DrawPhase: DrawPhase = 'draw_phase'

  export type Interact = ['interact', Interaction]
  export function Interact(interaction: Interaction): Interact {
    return ['interact', interaction]
  }

  export type PlayCard = ['play_card', CardId]
  export function PlayCard(cardId: CardId): PlayCard {
    return ['play_card', cardId]
  }

  export type StartGame = 'start_game'
  export const startGame: StartGame = 'start_game'

  export type UseAbility = [
    'use_expend_ability' | 'use_ally_ability' | 'use_sacrifice_ability',
    CardId
  ]
  export function UseAbility(ability: Ability, cardId: CardId): UseAbility {
    return [
      (() => {
        switch (ability) {
          case 'expend':
            return 'use_expend_ability'
          case 'ally':
            return 'use_ally_ability'
          case 'sacrifice':
            return 'use_sacrifice_ability'
        }
      })(),
      cardId
    ]
  }
}
