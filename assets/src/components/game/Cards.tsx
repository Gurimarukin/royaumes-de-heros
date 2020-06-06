/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, CSSProperties, useMemo } from 'react'
import { useTransition } from 'react-spring'

import { AnimatedCard, HiddenCard, Zone } from './CardComponent'
import { params } from '../../params'
import { PushSocket } from '../../models/PushSocket'
import { WithId } from '../../models/WithId'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Referentials } from '../../models/game/Referentials'
import { Coord } from '../../models/game/geometry/Coord'
import { Rectangle } from '../../models/game/geometry/Rectangle'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe, List } from '../../utils/fp'

interface Props {
  readonly call: PushSocket
  readonly game: Game
  readonly referentials: Referentials
  readonly zippedOtherPlayers: [Referential, WithId<OtherPlayer>][]
}

interface CardWithCoord {
  readonly card: WithId<Card>
  readonly playerId: string
  readonly zone: Zone
  readonly coord: Coord
}

type Cards = [CardWithCoord[], Coord[]]

export const Cards: FunctionComponent<Props> = ({
  call,
  game,
  referentials,
  zippedOtherPlayers
}) => {
  const [currentId, current] = game.player

  const [cards, hiddens]: Cards = useMemo(() => {
    const init: Cards = [
      [
        // market
        ...game.gems.map(card(referentials.market, _ => [0, 0], currentId, 'market')),
        ...game.market.map(
          card(
            referentials.market,
            i => [0, (i + 1) * params.card.heightPlusMargin],
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
    return pipe(
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

  const transitions = useTransition<CardWithCoord, Partial<CSSProperties & CardWithCoord>>(
    cards,
    ({ card: [cardId] }) => cardId,
    {
      // from: { left: 0, top: 0 },
      // leave: { left: 0, top: 0 },
      enter: ({ coord: [left, top] }) => ({ left, top }),
      update: ({ coord: [left, top] }) => ({ left, top }),
      leave: ({ coord: [left, top] }) => ({ left, top }),
      config: { precision: 10 }
    }
  )

  return (
    <div>
      {hiddens.map(([left, top], i) => (
        <HiddenCard key={i} style={{ left, top }} />
      ))}
      {transitions.map(({ item, key, props: { left, top } }) => (
        <AnimatedCard
          key={key}
          call={call}
          game={game}
          playerId={item.playerId}
          zone={item.zone}
          card={item.card}
          style={{ left, top }}
        />
      ))}
    </div>
  )
}

function fightZone(
  referential: Referential,
  cards: WithId<Card>[],
  playerId: string
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
  cards: WithId<Card>[],
  playerId: string
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
  playerId: string,
  zone: Zone
): (card: WithId<Card>, i: number) => CardWithCoord {
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
