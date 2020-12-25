/** @jsx jsx */
import { jsx } from '@emotion/core'
import {
  FunctionComponent,
  Profiler,
  ReactNode,
  useCallback,
  useContext,
  useMemo,
  useState,
} from 'react'

import { ChannelContext } from '../../contexts/ChannelContext'
import { ShowCardDetailContext } from '../../contexts/ShowCardDetailContext'
import { CallMessage } from '../../models/CallMessage'
import { Card } from '../../models/game/Card'
import { CardId } from '../../models/game/CardId'
import { Game as TGame } from '../../models/game/Game'
import { Referential } from '../../models/game/geometry/Referential'
import { OtherPlayer } from '../../models/game/OtherPlayer'
import { Player } from '../../models/game/Player'
import { PlayerId } from '../../models/PlayerId'
import { Either, Future, List, Maybe, Task, pipe } from '../../utils/fp'
import { BoardContainer } from './BoardContainer'
import { BoardThreeJs } from './BoardThreeJs'
import { CardsViewer } from './CardsViewer'
import { Confirm, ConfirmProps } from './Confirm'
import { Dialog } from './Dialog'
import { DialogProps } from './DialogStyled'
import { GameStyled } from './GameStyled'
import { RightBar } from './RightBar'

interface Props {
  readonly game: TGame
  readonly events: [number, string][]
}

export const Game: FunctionComponent<Props> = ({ game, events }) => {
  const referentials = useMemo(
    () => ({
      market: Referential.market,
      player: Referential.playerZone([0, 1]),
      others: Referential.otherPlayers(game.other_players.length),
    }),
    [game.other_players.length],
  )
  const zippedOtherPlayers = useMemo(() => List.zip(referentials.others, game.other_players), [
    game.other_players,
    referentials.others,
  ])

  // end turn
  const { call } = useContext(ChannelContext)
  const endTurn = useCallback(() => {
    pipe(
      CallMessage.DiscardPhase,
      call,
      Future.chain(
        Either.fold(
          _ => Future.right(undefined),
          _ =>
            pipe(
              CallMessage.DrawPhase,
              call,
              Task.delay(1000),
              Future.map(_ => {}),
            ),
        ),
      ),
      Future.runUnsafe,
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
    [game.other_players, game.player],
  )
  const closeDialog = useCallback(() => setDialogProps(_ => ({ ..._, shown: false })), [])

  // confirm
  const [confirmProps, setConfirmProps] = useState<ConfirmProps>(ConfirmProps.empty)
  const confirm = useCallback(
    (message: ReactNode, onConfirm: () => void) =>
      setConfirmProps({ hidden: false, message, onConfirm }),
    [],
  )
  const hideConfirm = useCallback(() => setConfirmProps(_ => ({ ..._, hidden: true })), [])

  return (
    <ShowCardDetailContext.Provider value={showCardDetail}>
      <GameStyled>
        {/* <BoardContainer
          game={game}
          referentials={referentials}
          zippedOtherPlayers={zippedOtherPlayers}
          showDiscard={showDiscard}
        /> */}
        <BoardThreeJs />
        <RightBar
          cardDetail={cardDetail}
          hideCardDetail={hideCardDetail}
          isCurrentPlayer={TGame.isCurrentPlayer(game)}
          isAlive={Player.isAlive(game.player[1])}
          endTurn={endTurn}
          confirm={confirm}
          events={events}
        />
        <Dialog closeDialog={closeDialog} game={game} props={dialogProps} />
        <Confirm hideConfirm={hideConfirm} confirm={confirmProps} />
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
  id: PlayerId,
): DialogProps {
  return pipe(
    player[0] === id
      ? {
          shown: true,
          title: 'Votre défausse',
          children: <CardsViewer cards={player[1].discard} />,
        }
      : pipe(
          others,
          List.findFirstMap(other => (other[0] === id ? Maybe.some(other[1]) : Maybe.none)),
          Maybe.fold<PartialPlayer, DialogProps>(
            () => ({ shown: false }),
            p => ({
              shown: true,
              title: `Défausse de ${p.name}`,
              children: <CardsViewer cards={p.discard} />,
            }),
          ),
        ),
  )
}
