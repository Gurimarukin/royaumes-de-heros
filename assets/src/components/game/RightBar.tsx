/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Chat } from './Chat'
import { ButtonUnderline } from '../Buttons'
import { params } from '../../params'

interface Props {
  readonly isCurrentPlayer: boolean
  readonly endTurnSent: boolean
  readonly endTurn: React.MouseEventHandler<HTMLButtonElement>
  readonly events: [number, string][]
}

export const RightBar: FunctionComponent<Props> = ({
  isCurrentPlayer,
  endTurnSent,
  endTurn,
  events
}) => (
  <div css={styles.container}>
    <div css={styles.cardDetail} />
    <Chat lines={events} css={styles.chat} />
    <div css={styles.buttons}>
      <ButtonUnderline
        disabled={endTurnSent}
        onClick={endTurn}
        css={styles.endTurnBtn}
        className={isCurrentPlayer ? 'current' : undefined}
      >
        Fin du tour
      </ButtonUnderline>
    </div>
  </div>
)

const styles = {
  container: css({
    position: 'relative',
    width: params.card.widthPlusMargin + params.card.margin,
    backgroundColor: 'black',
    borderLeft: '1px solid darkgoldenrod',
    paddingLeft: '1px',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'space-between'
  }),

  cardDetail: css({
    height: 'calc(50% - calc(0.8em + 7px))',
    border: '1px solid darkgoldenrod',
    borderWidth: '0 0 1px 1px',
    color: 'white',
    overflow: 'hidden'
  }),

  chat: css({
    height: 'calc(50% - calc(0.8em + 7px))',
    border: '1px solid darkgoldenrod',
    borderWidth: '1px 0 0 1px'
  }),

  buttons: css({
    position: 'absolute',
    right: 0,
    height: '100%',
    display: 'flex',
    alignItems: 'center'
  }),

  endTurnBtn: css({
    '&:not(.current)': {
      display: 'none'
    }
  })
}
