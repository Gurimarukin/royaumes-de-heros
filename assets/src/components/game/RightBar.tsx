/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Chat } from './Chat'
import { ButtonUnderline } from '../Buttons'
import { params } from '../../params'

interface Props {
  readonly isCurrentPlayer: boolean
  readonly endTurn: React.MouseEventHandler<HTMLButtonElement>
  readonly events: [number, string][]
}

export const RightBar: FunctionComponent<Props> = ({ isCurrentPlayer, endTurn, events }) => (
  <div css={styles.container}>
    <div css={styles.cardDetail} />
    <div css={styles.buttons}>
      <ButtonUnderline
        onClick={endTurn}
        css={styles.endTurnBtn}
        className={isCurrentPlayer ? 'current' : undefined}
      >
        Fin du tour
      </ButtonUnderline>
    </div>
    <Chat lines={events} css={styles.chat} />
  </div>
)

const styles = {
  container: css({
    position: 'relative',
    width: params.card.widthPlusMargin + params.card.margin,
    backgroundColor: 'black',
    borderLeft: '1px solid darkgoldenrod',
    paddingLeft: '2px',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between'
  }),

  cardDetail: css({
    flexGrow: 1,
    flexShrink: 0,
    flexBasis: 0,
    border: '1px solid darkgoldenrod',
    borderWidth: '0 0 1px 1px',
    color: 'white',
    overflow: 'hidden'
  }),

  buttons: css({
    display: 'flex',
    padding: '2px 0'
  }),

  chat: css({
    flexGrow: 1,
    flexShrink: 0,
    flexBasis: 0,
    border: '1px solid darkgoldenrod',
    borderWidth: '1px 0 0 1px'
  }),

  endTurnBtn: css({
    transition: 'opacity 0.2s',

    '&:not(.current)': {
      opacity: 0
    }
  })
}
