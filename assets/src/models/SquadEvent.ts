import * as D from 'io-ts/lib/Decoder'

interface PartialPlayer {
  readonly name: string
}

export namespace SquadEvent {
  const event = D.union(
    D.literal('start_game'),
    D.literal('lobby_joined'),
    D.literal('lobby_left'),
    D.literal('game_disconnected'),
    D.literal('game_reconnected')
  )

  export const codec = D.union(D.literal(null), D.literal('error'), D.tuple(D.string, event))

  export function pretty(): (event: SquadEvent) => string {
    return e => {
      if (e === null) return ''
      if (e === 'error') return 'Erreur'

      const [playerName, event] = e

      if (event === 'start_game') return 'Début de la partie'

      if (event === 'lobby_joined') {
        return `${playerName} a rejoint le salon`
      }

      if (event === 'lobby_left') {
        return `${playerName} a quitté le salon`
      }

      if (event === 'game_disconnected') {
        return `${playerName} s'est déconnecté`
      }

      if (event === 'game_reconnected') {
        return `${playerName} s'est reconnecté`
      }

      return JSON.stringify(event)
    }
  }
}

export type SquadEvent = D.TypeOf<typeof SquadEvent.codec>
