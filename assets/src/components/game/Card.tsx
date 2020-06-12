/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, ReactNode, useMemo, useCallback, useState } from 'react'
import { animated } from 'react-spring'

import { CardSimple } from './CardSimple'
import { BaseButton } from '../Buttons'
import { ClickOutside } from '../ClickOutside'
import { params } from '../../params'
import { CallChannel, CallMessage } from '../../models/CallMessage'
import { Ability } from '../../models/game/Ability'
import { Card as TCard } from '../../models/game/Card'
import { CardId } from '../../models/game/CardId'
import { Game } from '../../models/game/Game'
import { Interaction } from '../../models/game/Interaction'
import { PlayerId } from '../../models/PlayerId'
import { CardData } from '../../utils/CardData'
import { pipe, Maybe, Future } from '../../utils/fp'
import { AbilityIcon } from './AbilityIcon'

interface CommonProps {
  readonly style?: React.CSSProperties
}

type CardProps = {
  readonly call: CallChannel
  readonly showDiscard: (playerId: PlayerId) => void
  readonly showCardDetail: (key: string) => void
  readonly game: Game
  readonly playerId: PlayerId
  readonly card: [CardId, TCard]
  readonly zone: Zone
} & CommonProps

export type Zone = 'market' | 'hand' | 'fightZone' | 'discard'

type MouseEventHandler<A = HTMLElement> = (e: React.MouseEvent<A>) => void

const OPENED = 'opened'

export const Card: FunctionComponent<CardProps> = ({
  call,
  showDiscard,
  showCardDetail,
  game,
  playerId,
  card: [cardId, card],
  zone: zone,
  style
}) => {
  const callAndRun = useCallback((msg: CallMessage) => () => pipe(call(msg), Future.runUnsafe), [
    call
  ])

  const [abilitiesOpened, setAbilitiesOpened] = useState(false)
  const closeAbilities = useCallback(() => setAbilitiesOpened(false), [])
  const toggleAbilities = useCallback(() => setAbilitiesOpened(_ => !_), [])

  const ability = useCallback(
    (key: Ability, label: string, icon: AbilityIcon): JSX.Element => (
      <BaseButton onClick={callAndRun(CallMessage.UseAbility(key, cardId))} css={styles.ability}>
        <AbilityIcon icon={icon} css={styles.icon} /> <span>{label}</span>
      </BaseButton>
    ),
    [callAndRun, cardId]
  )

  const data = CardData.get(card.key)

  const isOther = game.player[0] !== playerId
  const isCurrent = Game.isCurrentPlayer(game)
  const pendingInteraction = Game.pendingInteraction(game)
  const onClick = useMemo<MouseEventHandler | undefined>(() => {
    switch (zone) {
      case 'market':
        return isCurrent ? callAndRun(CallMessage.BuyCard(cardId)) : undefined

      case 'hand':
        return !isOther && isCurrent ? callAndRun(CallMessage.PlayCard(cardId)) : undefined

      case 'fightZone':
        return pipe(
          pendingInteraction,
          Maybe.fold(
            () => {
              if (isCurrent) {
                return isOther
                  ? callAndRun(CallMessage.Attack(playerId, cardId))
                  : pipe(
                      data,
                      Maybe.map(({ expend, ally, sacrifice }) =>
                        expend || ally || sacrifice ? toggleAbilities : undefined
                      ),
                      Maybe.toUndefined
                    )
              }
              return undefined
            },
            interaction =>
              interaction === 'stun_champion' && isOther
                ? callAndRun(CallMessage.Interact(Interaction.StunChampion(playerId, cardId)))
                : interaction === 'prepare_champion' && !isOther
                ? callAndRun(CallMessage.Interact(Interaction.PrepareChampion(cardId)))
                : undefined
          )
        )

      case 'discard':
        return () => showDiscard(playerId)
    }
  }, [
    callAndRun,
    cardId,
    data,
    pendingInteraction,
    isCurrent,
    isOther,
    playerId,
    showDiscard,
    toggleAbilities,
    zone
  ])

  const onContextMenu = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault()
      showCardDetail(card.key)
    },
    [card.key, showCardDetail]
  )

  return (
    <ClickOutside onClickOutside={closeAbilities}>
      <div onClick={onClick} onContextMenu={onContextMenu} css={styles.container} style={style}>
        {pipe(
          data,
          Maybe.fold<CardData, ReactNode>(
            () => <CardSimple card={card} />,
            ({ faction, expend, ally, sacrifice }) => (
              <CardSimple card={card}>
                <div css={styles.abilities} className={abilitiesOpened ? OPENED : undefined}>
                  {expend && !card.expend_ability_used
                    ? ability('expend', 'Activer', 'expend')
                    : null}
                  {ally && !card.ally_ability_used && Maybe.isSome(faction)
                    ? ability('ally', 'Allié', faction.value)
                    : null}
                  {sacrifice ? ability('sacrifice', 'Sacrifice', 'sacrifice') : null}
                </div>
              </CardSimple>
            )
          )
        )}
      </div>
    </ClickOutside>
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

    '& > img': {
      width: '100%',
      height: '100%',
      borderRadius: params.card.borderRadius,
      boxShadow: '0 0 4px black'
    }
  }),

  abilities: css({
    position: 'absolute',
    left: abilityPadding,
    top: abilityPadding,
    width: params.card.width - 2 * abilityPadding,
    opacity: 0,
    borderRadius: '4px',
    overflow: 'hidden',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    transition: 'all 0.2s',
    boxShadow: '0 0 6px black',

    [`&.${OPENED}`]: {
      opacity: 1
    }
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
