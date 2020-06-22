/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useContext, useCallback } from 'react'

import { Params } from './Params'
import { Players } from './Players'
import { ButtonUnderline } from '../Buttons'
import { Chat } from '../Chat'
import { Link } from '../Link'
import { Router } from '../Router'
import { params } from '../../params'
import { ChannelContext } from '../../contexts/ChannelContext'
import { UserContext } from '../../contexts/UserContext'
import { CallMessage } from '../../models/CallMessage'
import { Lobby as TLobby } from '../../models/lobby/Lobby'
import { Future, pipe } from '../../utils/fp'

interface Props {
  readonly lobby: TLobby
  readonly events: [number, string][]
}

export const Lobby: FunctionComponent<Props> = ({ lobby, events }) => {
  const { user } = useContext(UserContext)
  const { call } = useContext(ChannelContext)

  const play = useCallback(() => pipe(CallMessage.startGame, call, Future.runUnsafe), [call])

  const isOwner = user.id === lobby.owner

  return (
    <div css={styles.container}>
      <div css={styles.params}>
        <Params lobby={lobby} />
      </div>
      <div css={styles.squad}>
        <Players lobby={lobby} />
      </div>
      <footer css={styles.footer}>
        {isOwner ? (
          <ButtonUnderline onClick={play} disabled={!lobby.ready}>
            Jouer
          </ButtonUnderline>
        ) : null}
        <Link to={Router.routes.squads} css={styles.leaveBtn}>
          Quitter
        </Link>
      </footer>
      <Chat lines={events} css={styles.chat} />
    </div>
  )
}

const styles = {
  container: css({
    width: '100vw',
    height: '100vh',
    backgroundImage: "url('/images/bg.jpg')",
    backgroundSize: '100% 100%',
    color: 'bisque',
    display: 'grid',
    gridTemplateColumns: `1fr 3fr ${params.card.widthPlusMargin + params.card.margin}px`,
    gridTemplateRows: '1fr auto',
    gridTemplateAreas: `
      "params squad chat"
      "footer footer footer"
    `
  }),

  params: css({
    gridArea: 'params'
  }),

  squad: css({
    gridArea: 'squad',
    padding: '.33em .67em',
    display: 'flex',
    justifyContent: 'center'
  }),

  footer: css({
    gridArea: 'footer',
    display: 'flex',
    justifyContent: 'center',
    padding: '0.67em 0',
    borderTop: '1px solid darkgoldenrod',
    backgroundColor: 'darkslateblue',

    '& > *': {
      margin: '0 0.67em'
    }
  }),

  leaveBtn: css({
    position: 'relative',
    textDecoration: 'none',
    lineHeight: 1,
    border: '3px solid',
    padding: '0.5em 0.6em 0.4em',
    transition: 'all 0.2s',
    cursor: 'inherit',
    color: 'white',
    backgroundColor: 'dimgrey',
    borderColor: 'dimgrey',

    '&::after': {
      content: `''`,
      position: 'absolute',
      bottom: '0.2em',
      left: '0.6em',
      width: 'calc(100% - 1.2em + 3px)',
      border: '1px solid',
      borderWidth: '1px 0',
      borderRadius: '50%',
      opacity: 0,
      transition: 'all 0.2s',
      borderColor: 'white'
    },

    '&:hover::after': {
      opacity: 1
    }
  }),

  chat: css({
    gridArea: 'chat',
    borderLeft: '1px solid darkgoldenrod'
  })
}
