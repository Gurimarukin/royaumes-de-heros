/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useCallback } from 'react'

import { CardSimple } from './CardSimple'
import { Card } from '../../models/game/Card'
import { Maybe, pipe } from '../../utils/fp'

interface Props {
  readonly card: Maybe<string>
  readonly hideCard: () => void
  readonly className?: string
}

export const CardDetail: FunctionComponent<Props> = ({ card, hideCard, className }) => {
  const onContextMenu = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault()
      hideCard()
    },
    [hideCard]
  )

  return (
    <div onContextMenu={onContextMenu} css={styles.container} className={className}>
      {pipe(
        card,
        Maybe.fold(
          () => <div css={styles.empty}>Clic droit sur une carte pour l'afficher</div>,
          _ => <CardSimple card={Card.fromKey(_)} />
        )
      )}
    </div>
  )
}

const styles = {
  container: css({
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    overflowY: 'auto',
    padding: '0 0.1em',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center'
  }),

  empty: css({
    textAlign: 'center',
    color: '#9f8d77',
    fontSize: '0.9em'
  })
}
