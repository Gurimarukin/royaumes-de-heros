/** @jsx jsx */
import { jsx } from '@emotion/core'
import styled from '@emotion/styled'
import { FunctionComponent, useCallback, useMemo, useContext } from 'react'

import { CardSelector } from './CardSelector'
import { DialogStyled, DialogProps } from './DialogStyled'
import { Effect } from './Effect'
import { ButtonUnderline, BaseButton, SecondaryButton } from '../Buttons'
import { ClickOutside } from '../ClickOutside'
import { ChannelContext } from '../../contexts/ChannelContext'
import { Diff } from '../../models/Diff'
import { CallMessage } from '../../models/CallMessage'
import { CardId } from '../../models/game/CardId'
import { Game } from '../../models/game/Game'
import { Interaction } from '../../models/game/Interaction'
import { PendingInteraction } from '../../models/game/PendingInteraction'
import { Player } from '../../models/game/Player'
import { pipe, Future, Maybe, Either } from '../../utils/fp'

interface Props {
  readonly closeDialog: () => void
  readonly game: Game
  readonly props: DialogProps
}

type Keys = Diff<keyof DialogProps, 'shown'>
type WithoutShown = {
  [K in Keys]?: DialogProps[K]
}

export const Dialog: FunctionComponent<Props> = ({ closeDialog, game, props }) => {
  const { call } = useContext(ChannelContext)
  const interact = useCallback(
    (interaction: Interaction) => () =>
      pipe(CallMessage.Interact(interaction), call, Future.runUnsafe),
    [call]
  )
  const interactCard = useCallback(
    (interaction: (id: CardId) => Interaction) => ([id]: CardId[]) => interact(interaction(id))(),
    [interact]
  )
  const interactCards = useCallback(
    (interaction: (ids: CardId[]) => Interaction) => (ids: CardId[]) =>
      interact(interaction(ids))(),
    [interact]
  )
  const [, player] = game.player

  const pendingInteraction = Game.pendingInteraction(game)

  const onClickOutside = useMemo(
    () => () => {
      pipe(
        pendingInteraction,
        Maybe.fold(
          () => closeDialog(),
          _ => {}
        )
      )
    },
    [closeDialog, pendingInteraction]
  )

  const res = pipe(
    pendingInteraction,
    Maybe.fold(
      () => props,
      _ => ({
        ...propsForInteraction(interact, interactCard, interactCards, player, _),
        shown: true
      })
    )
  )

  return (
    <ClickOutside onClickOutside={onClickOutside}>
      <DialogStyled {...res} />
    </ClickOutside>
  )
}

function propsForInteraction(
  interact: (msg: Interaction) => () => void,
  interactCard: (interaction: (id: CardId) => Interaction) => (ids: CardId[]) => void,
  interactCards: (interaction: (ids: CardId[]) => Interaction) => (ids: CardId[]) => void,
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
          onConfirm={interactCard(Interaction.DiscardCard)}
          cards={Either.right(player.hand)}
          confirmLabel={discardLabel}
        />
      )
    }
  }

  if (interaction === 'draw_then_discard') {
    return {
      title: "Vous pouvez piochez une carte. Si vous faites ainsi, défaussez vous d'une carte",
      children: (
        <Group>
          <ButtonUnderline onClick={interact(Interaction.DrawThenDiscard(true))}>
            Piocher
          </ButtonUnderline>
          <SecondaryButton onClick={interact(Interaction.DrawThenDiscard(false))}>
            Ne pas piocher
          </SecondaryButton>
        </Group>
      )
    }
  }

  if (interaction === 'prepare_champion') {
    return {
      title: 'Mobilisez un champion.'
    }
  }

  if (interaction === 'put_card_from_discard_to_deck') {
    return {
      title: `Mettez une carte de votre défausse au dessus de votre pioche.`,
      children: (
        <CardSelector
          amount={1}
          required={true}
          onConfirm={interactCard(Interaction.PutCardFromDiscardToDeck)}
          cards={Either.right(player.discard)}
          confirmLabel={chooseLabel}
        />
      )
    }
  }

  if (interaction === 'put_champion_from_discard_to_deck') {
    const champions = player.discard // TODO: filter only champions
    return {
      title: `Mettez un champion de votre défausse au dessus de votre pioche.`,
      children: (
        <CardSelector
          amount={1}
          required={true}
          onConfirm={interactCard(Interaction.PutChampionFromDiscardToDeck)}
          cards={Either.right(champions)}
          confirmLabel={chooseLabel}
        />
      )
    }
  }

  if (interaction === 'stun_champion') {
    return {
      title: 'Assommez un champion ennemi.'
    }
  }

  if (interaction === 'target_opponent_to_discard') {
    return {
      title: "Ciblez un adversaire qui devra se défausser d'une carte.",
      children: (
        <Group>
          <SecondaryButton onClick={interact(Interaction.TargetOpponentToDiscard(null))}>
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
      title: `Vous pouvez sacrifier ${ifNotOne("jusqu'à ")}${nToStr(amount, true)} carte${ifNotOne(
        's'
      )} de votre main ${ifNotOne('et/')}ou de votre défausse.`,
      children: (
        <CardSelector
          amount={amount}
          onConfirm={interactCards(Interaction.SacrificeFromHandOrDiscard)}
          cards={Either.left([
            ['Main', player.hand],
            ['Défausse', player.discard]
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
      title: 'Choisissez un effet.',
      children: (
        <Group>
          {effects.map((effect, i) => (
            <EffectButton key={i} onClick={interact(Interaction.SelectEffect(i))}>
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

function chooseLabel(): string {
  return 'Choisir'
}

function sacrificeLabel(ids: CardId[]): string {
  return ids.length === 0
    ? 'Ne pas sacrifier de carte'
    : `Sacrifier ${nToStr(ids.length, true)} carte${ids.length === 1 ? '' : 's'}`
}

const Group = styled.div({
  display: 'flex',
  justifyContent: 'center',
  padding: '0 1.67em',
  marginBottom: '1em',

  '& > button': {
    margin: '0 1em'
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
