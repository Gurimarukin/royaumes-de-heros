/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { CardDetail } from './CardDetail'
import { Chat } from '../Chat'
import { ButtonUnderline } from '../Buttons'
import { params } from '../../params'
import { Maybe } from '../../utils/fp'

interface Props {
  readonly cardDetail: Maybe<string>
  readonly hideCardDetail: () => void
  readonly isCurrentPlayer: boolean
  readonly endTurn: React.MouseEventHandler<HTMLButtonElement>
  readonly events: [number, string][]
}

export const RightBar: FunctionComponent<Props> = ({
  cardDetail,
  hideCardDetail,
  isCurrentPlayer,
  endTurn,
  events
}) => (
  <div css={styles.container}>
    <CardDetail card={cardDetail} hideCard={hideCardDetail} css={styles.cardDetail} />
    <div css={styles.buttons}>
      <ButtonUnderline
        disabled={!isCurrentPlayer}
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
    flex: '1 0 0',
    border: '1px solid darkgoldenrod',
    borderWidth: '0 0 1px 1px',
    overflow: 'hidden'
  }),

  buttons: css({
    display: 'flex',
    padding: '2px 0'
  }),

  chat: css({
    flex: '1 0 0',
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
