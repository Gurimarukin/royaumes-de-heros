import * as D from 'io-ts/lib/Decoder'

import { Effect } from './game/Effect'
import { CardData } from '../utils/CardData'
import { Dict, Maybe, pipe } from '../utils/fp'

export namespace SquadEvent {
  const interaction = D.union(
    D.tuple(D.literal('discard_card'), D.string),
    D.tuple(D.literal('draw_then_discard'), D.boolean),
    D.tuple(D.literal('prepare_champion'), D.string),
    D.tuple(D.literal('put_card_from_discard_to_deck'), D.string),
    D.tuple(D.literal('put_champion_from_discard_to_deck'), D.string),
    D.tuple(D.literal('stun_champion'), D.string, D.string),
    D.tuple(D.literal('target_opponent_to_discard'), D.nullable(D.string)),
    D.tuple(D.literal('sacrifice_from_hand_or_discard'), D.array(D.string)),
    D.tuple(D.literal('select_effect'), Effect.codec)
  )

  const event = D.union(
    D.literal('start_game'),
    D.literal('lobby_joined'),
    D.literal('lobby_left'),
    D.literal('game_disconnected'),
    D.literal('game_reconnected'),
    D.literal('discard_phase'),
    D.literal('new_turn'),
    D.tuple(D.literal('play_card'), D.string),
    D.tuple(D.literal('use_expend_ability'), D.string),
    D.tuple(D.literal('use_ally_ability'), D.string),
    D.tuple(D.literal('use_sacrifice_ability'), D.string),
    D.tuple(D.literal('buy_card'), D.string),
    D.tuple(D.literal('attack'), D.string, D.union(D.literal('player'), D.string)),
    D.tuple(D.literal('interact'), interaction)
  )

  export const codec = D.union(D.literal(null), D.literal('error'), D.tuple(D.string, event))

  export function pretty(cardData: Dict<CardData>): (event: SquadEvent) => Maybe<string> {
    return e => {
      if (e === null) return Maybe.none
      if (e === 'error') return Maybe.some('Erreur')

      const [playerName, event] = e

      if (event === 'start_game') return Maybe.some('Début de la partie')

      if (event === 'lobby_joined') {
        return Maybe.some(`${playerName} a rejoint le salon`)
      }

      if (event === 'lobby_left') {
        return Maybe.some(`${playerName} a quitté le salon`)
      }

      if (event === 'game_disconnected') {
        return Maybe.some(`${playerName} s'est déconnecté`)
      }

      if (event === 'game_reconnected') {
        return Maybe.some(`${playerName} s'est reconnecté`)
      }

      if (event === 'discard_phase') {
        return Maybe.some(`${playerName} : fin du tour`)
      }

      if (event === 'new_turn') {
        return Maybe.some(`${playerName} : début du tour`)
      }

      if (event[0] === 'play_card') {
        return Maybe.some(`${playerName} joue ${cardName(event[1])}`)
      }

      if (event[0] === 'use_expend_ability') {
        return Maybe.some(`${playerName} utilise la capacité Activer de ${cardName(event[1])}`)
      }

      if (event[0] === 'use_ally_ability') {
        return Maybe.some(`${playerName} utilise la capacité Allié de ${cardName(event[1])}`)
      }

      if (event[0] === 'use_sacrifice_ability') {
        return Maybe.some(`${playerName} utilise la capacité Sacrifier de ${cardName(event[1])}`)
      }

      if (event[0] === 'buy_card') {
        return Maybe.some(`${playerName} achète ${cardName(event[1])}`)
      }

      if (event[0] === 'attack') {
        if (event[2] === 'player') return Maybe.some(`${playerName} attaque ${event[1]}`)
        return Maybe.some(`${playerName} assome ${cardName(event[2])} (${event[1]})`)
      }

      if (event[0] === 'interact') {
        const interaction = event[1]

        if (interaction[0] === 'discard_card') {
          return Maybe.some(`${playerName} défausse ${cardName(interaction[1])}`)
        }

        if (interaction[0] === 'draw_then_discard') {
          return interaction[1] ? Maybe.some(`${playerName} pioche`) : Maybe.none
        }

        if (interaction[0] === 'prepare_champion') {
          return Maybe.some(`${playerName} mobilise ${cardName(interaction[1])}`)
        }

        if (
          interaction[0] === 'put_card_from_discard_to_deck' ||
          interaction[0] === 'put_champion_from_discard_to_deck'
        ) {
          return Maybe.some(`${playerName} met ${cardName(interaction[1])} sur sa pioche`)
        }

        if (interaction[0] === 'stun_champion') {
          return Maybe.some(
            `${playerName} assome ${cardName(interaction[2])} (${cardName(interaction[1])})`
          )
        }

        if (interaction[0] === 'target_opponent_to_discard') {
          if (interaction[1] === null) return Maybe.none
          return Maybe.some(`${playerName} fait se défausser ${interaction[1]}`)
        }

        if (interaction[0] === 'sacrifice_from_hand_or_discard') {
          if (interaction[1].length === 0) return Maybe.none
          return Maybe.some(`${playerName} sacrifie ${interaction[1].map(cardName).join(', ')}`)
        }

        if (interaction[0] === 'select_effect') {
          return Maybe.some(`${playerName} choisit l'effet ${Effect.pretty()(interaction[1])}`)
        }
      }

      return Maybe.some(JSON.stringify(event))

      function cardName(key: string): string | null {
        return pipe(
          Dict.lookup(key, cardData),
          Maybe.map(_ => _.name),
          Maybe.toNullable
        )
      }
    }
  }
}

export type SquadEvent = D.TypeOf<typeof SquadEvent.codec>
