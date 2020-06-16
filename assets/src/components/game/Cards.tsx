/** @jsx jsx */
import { jsx } from '@emotion/core'
import { ord, ordString } from 'fp-ts/lib/Ord'
import { FunctionComponent, useMemo } from 'react'

import { Card, HiddenCard, Zone } from './Card'
import { params } from '../../params'
import { PlayerId } from '../../models/PlayerId'
import { CallChannel } from '../../models/CallMessage'
import { Card as TCard } from '../../models/game/Card'
import { CardId } from '../../models/game/CardId'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Coord } from '../../models/game/geometry/Coord'
import { Rectangle } from '../../models/game/geometry/Rectangle'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe, List } from '../../utils/fp'

interface Props {
  readonly call: CallChannel
  readonly showDiscard: (playerId: PlayerId) => void
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, [PlayerId, OtherPlayer]][]
}

interface CardWithCoord {
  readonly card: [CardId, TCard]
  readonly playerId: PlayerId
  readonly zone: Zone
  readonly coord: Coord
}

type CardWithCoordWithI = CardWithCoord & { readonly i: number }

namespace CardWithCoordWithI {
  export const byId = ord.contramap(ordString, (c: CardWithCoordWithI) => CardId.unwrap(c.card[0]))
}

type Cards = [CardWithCoord[], Coord[]]
type CardsWithI = [CardWithCoordWithI[], Coord[]]

export const Cards: FunctionComponent<Props> = ({
  call,
  showDiscard,
  game,
  referentials,
  zippedOtherPlayers
}) => {
  const [currentId, current] = game.player

  const [cards, hiddens]: CardsWithI = useMemo(() => {
    const init: Cards = [
      [
        // market
        ...game.gems.map(card(referentials.market, _ => [0, 0], currentId, 'market')),
        ...game.market.map(
          card(
            referentials.market,
            i => [
              i < 2 ? 0 : params.card.widthPlusMargin,
              i < 2
                ? (i + 1) * params.card.heightPlusMargin
                : (i - 2) * params.card.heightPlusMargin
            ],
            currentId,
            'market'
          )
        ),

        // player
        ...discard(referentials.player, current.discard, currentId),
        ...hand(current.hand, left =>
          card(
            pipe(referentials.player, Referential.combine(Referential.bottomZone)),
            i => [left + i * params.card.widthPlusMargin, 0],
            currentId,
            'hand'
          )
        ),
        ...fightZone(referentials.player, current.fight_zone, currentId)
      ],
      [...deck(referentials.player, current.deck)]
    ]
    // others
    const res: Cards = pipe(
      zippedOtherPlayers,
      List.reduce(init, ([c, h], [referential, [playerId, player]]) => [
        [
          ...c,
          ...discard(referential, player.discard, playerId),
          ...fightZone(referential, player.fight_zone, playerId)
        ],
        [
          ...h,
          ...deck(referential, player.deck),
          ...hand(List.range(0, player.hand - 1), left =>
            hidden(pipe(referential, Referential.combine(Referential.bottomZone)), i => [
              left + i * params.card.widthPlusMargin,
              0
            ])
          )
        ]
      ])
    )
    return [
      pipe(
        res[0],
        List.mapWithIndex<CardWithCoord, CardWithCoordWithI>((i, c) => ({ ...c, i: i + 1 })),
        List.sortBy([CardWithCoordWithI.byId])
      ),
      res[1]
    ]
  }, [
    current.deck,
    current.discard,
    current.fight_zone,
    current.hand,
    currentId,
    game.gems,
    game.market,
    referentials.market,
    referentials.player,
    zippedOtherPlayers
  ])

  return (
    <div>
      {hiddens.map(([left, top], i) => (
        <HiddenCard key={i} style={{ left, top }} />
      ))}
      {cards.map(({ card: [cardId, card], playerId, zone, coord: [left, top], i: zIndex }) => (
        <Card
          key={CardId.unwrap(cardId)}
          call={call}
          showDiscard={showDiscard}
          game={game}
          playerId={playerId}
          zone={zone}
          card={[cardId, card]}
          style={{ left, top, zIndex }}
        />
      ))}
    </div>
  )
}

function fightZone(
  referential: Referential,
  cards: [CardId, TCard][],
  playerId: PlayerId
): CardWithCoord[] {
  const cardsWidth =
    Math.min(params.fightZone.columns, cards.length) * params.card.widthPlusMargin -
    params.card.margin
  const left = (params.fightZone.innerWidth - cardsWidth) / 2
  return cards.map(
    card(
      pipe(referential, Referential.combine(Referential.fightZone)),
      i => [
        i < params.fightZone.columns
          ? left + i * params.card.widthPlusMargin
          : params.fightZone.innerWidth -
            (i + 1 - params.fightZone.columns) * params.card.widthPlusMargin +
            params.card.margin,
        i < params.fightZone.columns ? 0 : params.card.heightPlusMargin
      ],
      playerId,
      'fightZone'
    )
  )
}

function discard(
  referential: Referential,
  cards: [CardId, TCard][],
  playerId: PlayerId
): CardWithCoord[] {
  return pipe(cards, List.reverse).map(
    card(
      pipe(referential, Referential.combine(Referential.bottomZone)),
      _i => [0, 0],
      playerId,
      'discard'
    )
  )
}

function card(
  referential: Referential,
  coord: (i: number) => Coord,
  playerId: PlayerId,
  zone: Zone
): (card: [CardId, TCard], i: number) => CardWithCoord {
  return (card, i) => ({
    card,
    playerId,
    zone,
    coord: pipe(referential, Referential.coord(Rectangle.card(coord(i))))
  })
}

function deck(referential: Referential, cards: number): Coord[] {
  return List.range(0, cards - 1).map(
    hidden(pipe(referential, Referential.combine(Referential.bottomZone)), _i => [
      params.bottomZone.width - params.card.width,
      0
    ])
  )
}

// array.length - i as key
function hidden(referential: Referential, coord: (i: number) => Coord): (i: number) => Coord {
  return i => pipe(referential, Referential.coord(Rectangle.card(coord(i))))
}

function hand<A, B>(cards: A[], f: (left: number) => (a: A, i: number) => B): B[] {
  const cardsWidth = cards.length * params.card.widthPlusMargin - params.card.margin
  const discardPlusInfos = 2 * params.card.widthPlusMargin
  const bottomZoneRemain = params.bottomZone.width - discardPlusInfos - params.card.widthPlusMargin
  const left = discardPlusInfos + (bottomZoneRemain - cardsWidth) / 2
  return cards.map(f(left))
}
