/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useCallback, useMemo } from 'react'

import { BoardContainer } from './BoardContainer'
import { CardsViewer } from './CardsViewer'
import { Dialog } from './Dialog'
import { DialogProps } from './DialogStyled'
import { RightBar } from './RightBar'
import { CallChannel, CallMessage } from '../../models/CallMessage'
import { Card } from '../../models/game/Card'
import { CardId } from '../../models/game/CardId'
import { PlayerId } from '../../models/PlayerId'
import { Game as TGame } from '../../models/game/Game'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Player } from '../../models/game/Player'
import { Referential } from '../../models/game/geometry/Referential'
import { pipe, List, Maybe, Future, Either, Task } from '../../utils/fp'
import { GameStyled } from './GameStyled'
import { ShowCardDetailContext } from '../../contexts/ShowCardDetailContext'

interface Props {
  readonly call: CallChannel
  readonly game: TGame
  readonly events: [number, string][]
}

export const Game: FunctionComponent<Props> = ({ call, game, events }) => {
  const referentials = useMemo(
    () => ({
      market: Referential.market,
      player: Referential.playerZone([0, 1]),
      others: Referential.otherPlayers(game.other_players.length)
    }),
    [game.other_players.length]
  )
  const zippedOtherPlayers = List.zip(referentials.others, game.other_players)

  // end turn
  const endTurn = useCallback(() => {
    pipe(
      call(CallMessage.DiscardPhase),
      Future.chain(
        Either.fold(
          _ => Future.right(undefined),
          _ =>
            pipe(
              call(CallMessage.DrawPhase),
              Task.delay(1000),
              Future.map(_ => {})
            )
        )
      ),
      Future.runUnsafe
    )
  }, [call])

  // card detail
  const [cardDetail, setCardDetail] = useState<Maybe<string>>(Maybe.none)
  const showCardDetail = useCallback((key: string) => setCardDetail(Maybe.some(key)), [])
  const hideCardDetail = useCallback(() => setCardDetail(Maybe.none), [])

  // dialog
  const [dialogProps, setDialogProps] = useState<DialogProps>({ shown: false })
  const showDiscard = useCallback(
    (id: PlayerId) => setDialogProps(discardDialogProps(game.player, game.other_players, id)),
    [game.other_players, game.player]
  )
  const closeDialog = useCallback(() => setDialogProps(_ => ({ ..._, shown: false })), [])

  return (
    <ShowCardDetailContext.Provider value={showCardDetail}>
      <GameStyled>
        <BoardContainer
          call={call}
          game={game}
          referentials={referentials}
          zippedOtherPlayers={zippedOtherPlayers}
          showDiscard={showDiscard}
        />
        <RightBar
          cardDetail={cardDetail}
          hideCardDetail={hideCardDetail}
          isCurrentPlayer={TGame.isCurrentPlayer(game)}
          endTurn={endTurn}
          events={events}
        />
        <Dialog call={call} closeDialog={closeDialog} game={game} props={dialogProps} />
      </GameStyled>
    </ShowCardDetailContext.Provider>
  )
}

interface PartialPlayer {
  readonly name: string
  readonly discard: [CardId, Card][]
}

function discardDialogProps(
  player: [PlayerId, Player],
  others: [PlayerId, OtherPlayer][],
  id: PlayerId
): DialogProps {
  return pipe(
    player[0] === id
      ? {
          shown: true,
          title: 'Votre défausse',
          children: <CardsViewer cards={player[1].discard} />
        }
      : pipe(
          others,
          List.findFirstMap(other => (other[0] === id ? Maybe.some(other[1]) : Maybe.none)),
          Maybe.fold<PartialPlayer, DialogProps>(
            () => ({ shown: false }),
            p => ({
              shown: true,
              title: `Défausse de ${p.name}`,
              children: <CardsViewer cards={p.discard} />
            })
          )
        )
  )
}
