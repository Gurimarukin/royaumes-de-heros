/** @jsx jsx */
import { jsx } from '@emotion/core'
import styled from '@emotion/styled'
import { FunctionComponent, useCallback } from 'react'

import { CardSelector } from './CardSelector'
import { DialogStyled, DialogProps } from './DialogStyled'
import { Effect } from './Effect'
import { ButtonUnderline, BaseButton } from '../Buttons'
import { Diff } from '../../models/Diff'
import { PushSocket } from '../../models/PushSocket'
import { Game } from '../../models/game/Game'
import { PendingInteraction } from '../../models/game/PendingInteraction'
import { Player } from '../../models/game/Player'
import { pipe, Future, Maybe, Either } from '../../utils/fp'

interface Props {
  readonly call: PushSocket
  readonly game: Game
  readonly props: DialogProps
}

type Keys = Diff<keyof DialogProps, 'shown'>
type WithoutShown = {
  [K in Keys]: DialogProps[K]
}

export const Dialog: FunctionComponent<Props> = ({ call, game, props }) => {
  const interact = useCallback(
    (interaction: any) => () => pipe(call(['interact', interaction]), Future.runUnsafe),
    [call]
  )
  const discardCard = useCallback(([cardId]: string[]) => interact(['discard_card', cardId])(), [
    interact
  ])
  const sacrificeCards = useCallback(
    (cardIds: string[]) => interact(['sacrifice_from_hand_or_discard', cardIds])(),
    [interact]
  )
  const [, player] = game.player
  const res = pipe(
    Game.pendingInteraction(game),
    Maybe.fold(
      () => props,
      _ => ({
        ...propsForInteraction(interact, discardCard, sacrificeCards, player, _),
        shown: true
      })
    )
  )
  return <DialogStyled {...res} />
}

function propsForInteraction(
  interact: (msg: any) => () => void,
  discardCard: (cardIds: string[]) => void,
  sacrificeCards: (cardIds: string[]) => void,
  player: Player,
  interaction: PendingInteraction
): WithoutShown {
  if (interaction === 'discard_card') {
    return {
      title: `Vous devez vous défausser d'une carte de votre main.`,
      children: (
        <CardSelector
          amount={1}
          required={true}
          onConfirm={discardCard}
          cards={Either.right(player.hand)}
          confirmLabel={discardLabel}
        />
      )
    }
  }

  if (interaction === 'draw_then_discard') return unknown(interaction)

  if (interaction === 'prepare_champion') return unknown(interaction)

  if (interaction === 'put_card_from_discard_to_deck') return unknown(interaction)

  if (interaction === 'put_champion_from_discard_to_deck') return unknown(interaction)

  if (interaction === 'stun_champion') return unknown(interaction)

  if (interaction === 'target_opponent_to_discard') {
    return {
      title: "Choisissez un adversaire qui devra se défausser d'une carte.",
      children: (
        <Group>
          <SecondaryButton onClick={interact(['target_opponent_to_discard', null])}>
            Ne cibler aucun adversaire
          </SecondaryButton>
        </Group>
      )
    }
  }

  if (interaction[0] === 'sacrifice_from_hand_or_discard') {
    const amount = Math.min(interaction[1].amount, player.hand.length + player.discard.length)
    const ifNotOne = (orElse: string): string => (amount === 1 ? '' : orElse)

    return {
      title: `Choisissez ${nToStr(amount, true)} carte${ifNotOne(
        's'
      )} à sacrifier de votre main ${ifNotOne('et/')}ou votre défausse.`,
      children: (
        <CardSelector
          amount={amount}
          onConfirm={sacrificeCards}
          cards={Either.left([
            ['Main :', player.hand],
            ['Défausse :', player.discard]
          ])}
          confirmLabel={sacrificeLabel}
        />
      )
    }
  }

  if (interaction[0] === 'select_effect') {
    const effects = interaction[1]
    const championsInFightZone = 0 // TODO

    return {
      title: `Choisissez l'un de ces ${nToStr(effects.length)} effets.`,
      children: (
        <Group>
          {effects.map((effect, i) => (
            <EffectButton key={i} onClick={interact(['select_effect', i])}>
              <Effect effect={effect} championsInFightZone={championsInFightZone} />
            </EffectButton>
          ))}
        </Group>
      )
    }
  }

  return unknown(interaction)
}

function unknown(interaction: unknown): WithoutShown {
  return {
    title: 'Interaction inconnue',
    children: <pre>{JSON.stringify(interaction, null, 2)}</pre>
  }
}

function nToStr(n: number, f = false): string {
  if (n === 1) return f ? 'une' : 'un'
  if (n === 2) return 'deux'
  if (n === 3) return 'trois'
  return String(n)
}

function discardLabel(): string {
  return 'Défausser'
}

function sacrificeLabel(cardIds: string[]): string {
  return cardIds.length === 0
    ? 'Ne pas sacrifier de carte'
    : `Sacrifier ${nToStr(cardIds.length, true)} carte${cardIds.length === 1 ? '' : 's'}`
}

const Group = styled.div({
  display: 'flex',
  justifyContent: 'center',
  marginBottom: '1em'
})

const SecondaryButton = styled(ButtonUnderline)({
  backgroundColor: 'dimgrey',
  borderColor: 'dimgrey',

  color: 'white',
  '&::after': {
    borderColor: 'white',
    bottom: '0.1em'
  }
})

const EffectButton = styled(BaseButton)({
  backgroundColor: '#222222',
  color: 'white',
  border: '2px solid goldenrod',
  borderRadius: '10px',
  margin: '0 0.5em',
  width: '6em',
  padding: '1em 0',
  fontWeight: 'bold',
  fontSize: '1.1em',
  flexDirection: 'row',
  justifyContent: 'center',
  alignItems: 'center',

  '&:not(:disabled):hover': {
    backgroundColor: '#755811'
  },

  '& > svg': {
    height: '2em',
    marginRight: '1em'
  }
})
