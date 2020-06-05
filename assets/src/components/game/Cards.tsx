/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, Fragment } from 'react'

import { CardComponent, HiddenCard, Zone } from './CardComponent'
import { params } from '../../params'
import { WithId } from '../../models/WithId'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Coord } from '../../models/game/geometry/Coord'
import { Rectangle } from '../../models/game/geometry/Rectangle'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe, List, Future, Either } from '../../utils/fp'

interface Props {
  readonly call: (msg: any) => Future<Either<void, void>>
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, WithId<OtherPlayer>][]
}

export const Cards: FunctionComponent<Props> = ({
  call,
  game,
  referentials,
  zippedOtherPlayers
}) => {
  const [currentId, current] = game.player

  return (
    <div>
      {/* market */}
      {game.gems.map(card(referentials.market, _ => [0, 0], currentId, 'market'))}
      {game.market.map(
        card(
          referentials.market,
          i => [0, (i + 1) * params.card.heightPlusMargin],
          currentId,
          'market'
        )
      )}

      {/* player */}
      {deck(referentials.player, current.deck)}
      {discard(referentials.player, current.discard, currentId)}
      {current.hand.map(
        card(
          pipe(referentials.player, Referential.combine(Referential.bottomZone)),
          i => [(i + 2) * params.card.widthPlusMargin, 0],
          currentId,
          'hand'
        )
      )}
      {fightZone(referentials.player, current.fight_zone, currentId)}

      {/* others */}
      {zippedOtherPlayers.map(([referential, [playerId, player]]) => (
        <Fragment key={playerId}>
          {deck(referential, player.deck)}
          {discard(referential, player.discard, playerId)}
          {List.range(2, player.hand + 1).map(
            hidden(pipe(referential, Referential.combine(Referential.bottomZone)), i => [
              i * params.card.widthPlusMargin,
              0
            ])
          )}
          {fightZone(referential, player.fight_zone, playerId)}
        </Fragment>
      ))}
    </div>
  )

  function card(
    referential: Referential,
    coord: (i: number) => Coord,
    playerId: string,
    zone: Zone
  ): (card: [string, Card], i: number) => JSX.Element {
    return ([cardId, card], i) => {
      const [left, top] = pipe(referential, Referential.coord(Rectangle.card(coord(i))))

      return (
        <CardComponent
          key={cardId}
          call={call}
          game={game}
          playerId={playerId}
          zone={zone}
          card={[cardId, card]}
          style={{ left, top }}
        />
      )
    }
  }

  function fightZone(
    referential: Referential,
    cards: WithId<Card>[],
    playerId: string
  ): JSX.Element[] {
    return cards.map(
      card(
        pipe(referential, Referential.combine(Referential.fightZone)),
        i => [(i + 1) * params.card.widthPlusMargin, 0],
        playerId,
        'fightZone'
      )
    )
  }

  function discard(
    referential: Referential,
    cards: WithId<Card>[],
    playerId: string
  ): JSX.Element[] {
    return cards.map(
      card(
        pipe(referential, Referential.combine(Referential.bottomZone)),
        _i => [0, 0],
        playerId,
        'discard'
      )
    )
  }
}

function deck(referential: Referential, cards: number): JSX.Element[] {
  return List.range(0, cards - 1).map(
    hidden(pipe(referential, Referential.combine(Referential.bottomZone)), _i => [
      params.bottomZone.width - params.card.width,
      0
    ])
  )
}

// array.length - i as key
function hidden(referential: Referential, coord: (i: number) => Coord): (i: number) => JSX.Element {
  return i => {
    const [left, top] = pipe(referential, Referential.coord(Rectangle.card(coord(i))))
    return <HiddenCard key={i} style={{ left, top }} />
  }
}
