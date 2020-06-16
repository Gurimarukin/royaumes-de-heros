/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useMemo, useCallback, useContext } from 'react'
import { animated } from 'react-spring'

import { AbilityIcon } from './AbilityIcon'
import { CardSimpleWithIcons } from './CardSimpleWithIcons'
import { BaseButton } from '../Buttons'
import { params } from '../../params'
import { CardDatasContext } from '../../contexts/CardDatasContext'
import { ShowCardDetailContext } from '../../contexts/ShowCardDetailContext'
import { CallChannel, CallMessage } from '../../models/CallMessage'
import { PlayerId } from '../../models/PlayerId'
import { Ability } from '../../models/game/Ability'
import { Card as TCard } from '../../models/game/Card'
import { CardId } from '../../models/game/CardId'
import { CardData, Faction, CardType } from '../../models/game/CardData'
import { Game } from '../../models/game/Game'
import { Interaction } from '../../models/game/Interaction'
import { pipe, Maybe, Future, Dict } from '../../utils/fp'

interface CommonProps {
  readonly style?: React.CSSProperties
}

type CardProps = {
  readonly call: CallChannel
  readonly showDiscard: (playerId: PlayerId) => void
  readonly game: Game
  readonly playerId: PlayerId
  readonly card: [CardId, TCard]
  readonly zone: Zone
} & CommonProps

export type Zone = 'market' | 'hand' | 'fightZone' | 'discard'

type Abilities = Readonly<Record<Ability, boolean>> & { readonly faction: Faction }

type OnClickAndCursor = [Maybe<React.MouseEventHandler>, Maybe<Cursor>]
function OnClickAndCursor(onClick?: React.MouseEventHandler, cursor?: Cursor): OnClickAndCursor {
  return [Maybe.fromNullable(onClick), Maybe.fromNullable(cursor)]
}

type Cursor = string
namespace Cursor {
  export const ATTACK = 'attack'
  export const BAN = 'ban'
  export const BUY = 'buy'
  export const EYE = 'eye'
  export const STAR = 'star'
}

const ABILITIES = 'abilities'

export const Card: FunctionComponent<CardProps> = props => {
  const card = props.card[1]
  const cardDatas = useContext(CardDatasContext)
  const data = Dict.lookup(card.key, cardDatas)

  return pipe(
    data,
    Maybe.fold(
      () => (
        <div css={[styles.container, styles.transitionLeftTop]}>
          <CardSimpleWithIcons card={card} />
        </div>
      ),
      _ => <SomeCard props={props} cardDatas={cardDatas} data={_} />
    )
  )
}

interface SomeCardProps {
  readonly props: CardProps
  readonly cardDatas: Dict<CardData>
  readonly data: CardData
}

const SomeCard: FunctionComponent<SomeCardProps> = ({
  props: {
    call,
    showDiscard,
    game,
    playerId,
    card: [cardId, card],
    zone: zone,
    style
  },
  cardDatas,
  data
}) => {
  const callAndRun = useCallback((msg: CallMessage) => () => pipe(call(msg), Future.runUnsafe), [
    call
  ])

  const ability = useCallback(
    (key: Ability, label: string, icon: AbilityIcon): JSX.Element => (
      <BaseButton onClick={callAndRun(CallMessage.UseAbility(key, cardId))} css={styles.ability}>
        <AbilityIcon icon={icon} css={styles.icon} /> <span>{label}</span>
      </BaseButton>
    ),
    [callAndRun, cardId]
  )

  const isOther = game.player[0] !== playerId
  const isCurrent = Game.isCurrentPlayer(game)
  const pendingInteraction = Game.pendingInteraction(game)

  const abilities: Maybe<Abilities> = pipe(
    pendingInteraction,
    Maybe.fold(
      () =>
        zone === 'fightZone' && isCurrent && !isOther && Maybe.isSome(data.faction)
          ? Maybe.some({
              expend: data.expend && !card.expend_ability_used,
              ally:
                data.ally &&
                !card.ally_ability_used &&
                2 <=
                  CardData.countFaction(cardDatas, game.player[1].fight_zone, data.faction.value),
              sacrifice: data.sacrifice,
              faction: data.faction.value
            })
          : Maybe.none,
      _ => Maybe.none
    )
  )

  const onClickAndCursor = useMemo<Maybe<OnClickAndCursor>>(() => {
    switch (zone) {
      case 'market':
        if (isCurrent) {
          const cost = pipe(
            data.cost,
            Maybe.getOrElse(() => 0)
          )
          if (cost <= game.player[1].gold) {
            return Maybe.some(OnClickAndCursor(callAndRun(CallMessage.BuyCard(cardId)), Cursor.BUY))
          }
          return Maybe.some(OnClickAndCursor(undefined, Cursor.BAN))
        }
        return Maybe.none

      case 'hand':
        return !isOther && isCurrent
          ? Maybe.some(OnClickAndCursor(callAndRun(CallMessage.PlayCard(cardId))))
          : Maybe.none

      case 'fightZone':
        return pipe(
          pendingInteraction,
          Maybe.fold(
            () => {
              if (isCurrent) {
                if (isOther) {
                  if (CardType.isChampion(data.type)) {
                    // TODO: take defense modifiers into account
                    const defense = data.type[1]
                    if (game.player[1].combat < defense) {
                      return Maybe.some(OnClickAndCursor(undefined, Cursor.BAN))
                    }

                    const attack = callAndRun(CallMessage.Attack(playerId, cardId))

                    if (
                      CardType.isGuard(data.type) ||
                      CardData.countGuards(cardDatas, game.player[1].fight_zone) === 0
                    ) {
                      return Maybe.some(OnClickAndCursor(attack, Cursor.ATTACK))
                    }

                    return Maybe.some(OnClickAndCursor(undefined, Cursor.BAN))
                  }
                  return Maybe.none
                }
                return pipe(
                  abilities,
                  Maybe.filter(({ expend, ally, sacrifice }) => expend || ally || sacrifice),
                  Maybe.map(_ => OnClickAndCursor(undefined, Cursor.STAR))
                )
              }
              return Maybe.none
            },
            interaction =>
              interaction === 'stun_champion' && isOther
                ? Maybe.some(
                    OnClickAndCursor(
                      callAndRun(CallMessage.Interact(Interaction.StunChampion(playerId, cardId))),
                      Cursor.ATTACK
                    )
                  )
                : interaction === 'prepare_champion' && !isOther
                ? Maybe.some(
                    OnClickAndCursor(
                      callAndRun(CallMessage.Interact(Interaction.PrepareChampion(cardId))),
                      Cursor.STAR
                    )
                  )
                : Maybe.none
          )
        )

      case 'discard':
        return Maybe.some(OnClickAndCursor(() => showDiscard(playerId), Cursor.EYE))
    }
  }, [
    abilities,
    callAndRun,
    cardDatas,
    cardId,
    data.cost,
    data.type,
    game.player,
    isCurrent,
    isOther,
    pendingInteraction,
    playerId,
    showDiscard,
    zone
  ])

  const onClick = pipe(
    onClickAndCursor,
    Maybe.chain(([_]) => _),
    Maybe.toUndefined
  )
  const cursor = pipe(
    onClickAndCursor,
    Maybe.chain(([, _]) => _),
    Maybe.toUndefined
  )

  const showCardDetail = useContext(ShowCardDetailContext)
  const onContextMenu = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault()
      showCardDetail(card.key)
    },
    [card.key, showCardDetail]
  )

  return pipe(
    abilities,
    Maybe.fold(
      () => (
        <CardSimpleWithIcons
          card={card}
          onClick={onClick}
          onContextMenu={onContextMenu}
          css={[styles.container, styles.transitionLeftTop]}
          className={cursor}
          style={style}
        />
      ),
      ({ faction, expend, ally, sacrifice }) => (
        <CardSimpleWithIcons
          card={card}
          onClick={onClick}
          onContextMenu={onContextMenu}
          css={[styles.container, styles.transitionLeftTop]}
          className={cursor}
          style={style}
        >
          <div className={ABILITIES}>
            {expend ? ability('expend', 'Activer', 'expend') : null}
            {ally ? ability('ally', 'Allié', faction) : null}
            {sacrifice ? ability('sacrifice', 'Sacrifice', 'sacrifice') : null}
          </div>
        </CardSimpleWithIcons>
      )
    )
  )
}

export const AnimatedCard = animated(Card)

export const HiddenCard: FunctionComponent<CommonProps> = ({ style }) => (
  <div css={styles.container} style={style}>
    <img src={CardData.hidden} />
  </div>
)

const abilityPadding = 0.05 * params.card.width
const styles = {
  container: css({
    position: 'absolute',
    // willChange: 'left, top',

    [`&.${Cursor.ATTACK}`]: {
      cursor: "url('/images/cursors/swords.svg'), auto"
    },

    [`&.${Cursor.BAN}`]: {
      cursor: "url('/images/cursors/ban.svg'), auto"
    },

    [`&.${Cursor.BUY}`]: {
      cursor: "url('/images/cursors/coin.svg'), auto"
    },

    [`&.${Cursor.EYE}`]: {
      cursor: "url('/images/cursors/eye.svg'), auto"
    },

    [`&.${Cursor.STAR}`]: {
      cursor: "url('/images/cursors/star.svg'), auto"
    },

    '& > img': {
      width: '100%',
      height: '100%',
      borderRadius: params.card.borderRadius,
      boxShadow: '0 0 4px black'
    },

    [`& .${ABILITIES}`]: {
      position: 'absolute',
      left: abilityPadding,
      top: abilityPadding,
      width: params.card.width - 2 * abilityPadding,
      opacity: 0,
      visibility: 'hidden',
      borderRadius: '4px',
      overflow: 'hidden',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      transition: 'all 0.2s',
      boxShadow: '0 0 6px black'
    },

    [`&:hover .${ABILITIES}`]: {
      visibility: 'visible',
      opacity: 1
    }
  }),

  transitionLeftTop: css({
    transition: 'left 1s, top 1s'
  }),

  ability: css({
    width: '100%',
    border: 'none',
    fontSize: '1.9em',
    padding: '0.2em 0.4em 0.2em 0.2em',
    transition: 'all 0.2s',
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',

    '&:hover': {
      backgroundColor: '#c1bda1'
    }
  }),

  icon: css({
    boxShadow: 'none'
  })
}
