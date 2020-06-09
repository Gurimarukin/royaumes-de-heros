import { CardId } from './CardId'
import { PlayerId } from '../PlayerId'

export type Interaction =
  | Interaction.DiscardCard
  | Interaction.DrawThenDiscard
  | Interaction.PrepareChampion
  | Interaction.PutCardFromDiscardToDeck
  | Interaction.PutChampionFromDiscardToDeck
  | Interaction.SacrificeFromHandOrDiscard
  | Interaction.SelectEffect
  | Interaction.StunChampion
  | Interaction.TargetOpponentToDiscard

export namespace Interaction {
  export type DiscardCard = ['discard_card', CardId]
  export function DiscardCard(id: CardId): DiscardCard {
    return ['discard_card', id]
  }

  export type DrawThenDiscard = ['draw_then_discard', boolean]
  export function DrawThenDiscard(draw: boolean): DrawThenDiscard {
    return ['draw_then_discard', draw]
  }

  export type PrepareChampion = ['prepare_champion', CardId]
  export function PrepareChampion(id: CardId): PrepareChampion {
    return ['prepare_champion', id]
  }

  export type PutCardFromDiscardToDeck = ['put_card_from_discard_to_deck', CardId]
  export function PutCardFromDiscardToDeck(id: CardId): PutCardFromDiscardToDeck {
    return ['put_card_from_discard_to_deck', id]
  }

  export type PutChampionFromDiscardToDeck = ['put_champion_from_discard_to_deck', CardId]
  export function PutChampionFromDiscardToDeck(id: CardId): PutChampionFromDiscardToDeck {
    return ['put_champion_from_discard_to_deck', id]
  }

  export type SacrificeFromHandOrDiscard = ['sacrifice_from_hand_or_discard', CardId[]]
  export function SacrificeFromHandOrDiscard(ids: CardId[]): SacrificeFromHandOrDiscard {
    return ['sacrifice_from_hand_or_discard', ids]
  }

  export type SelectEffect = ['select_effect', number]
  export function SelectEffect(i: number): SelectEffect {
    return ['select_effect', i]
  }

  export type StunChampion = ['stun_champion', PlayerId, CardId]
  export function StunChampion(playerId: PlayerId, cardId: CardId): StunChampion {
    return ['stun_champion', playerId, cardId]
  }

  export type TargetOpponentToDiscard = ['target_opponent_to_discard', null | PlayerId]
  export function TargetOpponentToDiscard(opponent: null | PlayerId): TargetOpponentToDiscard {
    return ['target_opponent_to_discard', opponent]
  }
}
