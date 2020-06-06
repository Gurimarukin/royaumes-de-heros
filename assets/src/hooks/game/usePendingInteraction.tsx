/** @jsx jsx */
import { jsx } from '@emotion/core'
import styled from '@emotion/styled'
import { useCallback, useEffect, Dispatch, SetStateAction } from 'react'

import { DialogProps } from '../../components/game/Dialog'
import { BaseButton } from '../../components/BaseButton'
import { CallGame } from '../../models/game/CallGame'
import { Game } from '../../models/game/Game'
import { pipe, Future, Maybe, flow } from '../../utils/fp'
import { DialogState } from '../../models/game/DialogState'
import { PendingInteraction } from '../../models/game/PendingInteraction'

export function usePendingInteraction(
  call: CallGame,
  game: Game,
  setDialogState: Dispatch<SetStateAction<DialogState<DialogProps>>>
): void {
  const callAndRun = useCallback((msg: any) => () => pipe(call(msg), Future.runUnsafe), [call])
  const [interaction] = game.player[1].pending_interactions

  useEffect(() => {
    pipe(
      props(callAndRun, interaction),
      Maybe.fold(
        () =>
          setDialogState(prev =>
            DialogState.isInteraction(prev) ? { ...prev, shown: false } : prev
          ),
        flow(DialogState.Interaction, setDialogState)
      )
    )
    interaction
  }, [callAndRun, interaction, setDialogState])
}

function props(
  callAndRun: (msg: any) => () => void,
  interaction: PendingInteraction | undefined
): Maybe<DialogProps> {
  if (interaction === undefined) return Maybe.none

  if (interaction === 'target_opponent_to_discard') {
    return Maybe.some({
      shown: true,
      title: "Cibler un adversaire qui devra se défausser d'une carte.",
      children: (
        <SecondaryButton onClick={callAndRun(['interact', ['target_opponent_to_discard', null]])}>
          Ne cibler aucun adversaire
        </SecondaryButton>
      )
    })
  }

  return Maybe.some({
    shown: true,
    title: 'Interaction inconnue',
    children: <pre>{JSON.stringify(interaction, null, 2)}</pre>
  })
}

const SecondaryButton = styled(BaseButton)({
  margin: '0 auto 1em',

  backgroundColor: 'dimgrey',
  borderColor: 'dimgrey',

  color: 'white',
  '&::after': {
    borderColor: 'white',

    bottom: '0.1em'
  }
})
