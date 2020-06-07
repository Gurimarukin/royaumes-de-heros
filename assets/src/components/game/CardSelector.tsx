/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useState, useCallback, ReactNode, Fragment } from 'react'

import { CardsViewer } from './CardsViewer'
import { ButtonUnderline } from '../Buttons'
import { WithId } from '../../models/WithId'
import { Card } from '../../models/game/Card'
import { List, pipe, Either } from '../../utils/fp'

interface Props {
  readonly amount: number
  readonly required?: boolean
  readonly onConfirm: (cardIds: string[]) => void
  readonly cards: Either<[string, WithId<Card>[]][], WithId<Card>[]>
  readonly confirmLabel: (cardIds: string[]) => ReactNode
}

export const CardSelector: FunctionComponent<Props> = ({
  amount,
  required = false,
  onConfirm,
  cards: eitherCards,
  confirmLabel
}) => {
  const [selected, setSelected] = useState<string[]>([])

  const toggleCard = useCallback(
    (cardId: string) => () =>
      setSelected(prev =>
        pipe(
          prev,
          List.exists(_ => _ === cardId)
        )
          ? pipe(
              prev,
              List.filter(_ => _ !== cardId)
            )
          : prev.length === amount
          ? pipe(prev, ([, ...tail]) => List.snoc(tail, cardId))
          : List.snoc(prev, cardId)
      ),
    [amount]
  )
  const confirm = useCallback(() => onConfirm(selected), [onConfirm, selected])

  return (
    <div onWheel={stopPropagation} css={styles.container}>
      {pipe(
        eitherCards,
        Either.fold(
          blocks => (
            <Fragment>
              {blocks.map(([label, cards], i) =>
                cards.length === 0 ? null : (
                  <div key={i} css={styles.block}>
                    <div css={styles.blockLabel}>{label}</div>
                    <CardsViewer selected={selected} toggleCard={toggleCard} cards={cards} />
                  </div>
                )
              )}
            </Fragment>
          ),
          _ => <CardsViewer selected={selected} toggleCard={toggleCard} cards={_} />
        )
      )}
      <ButtonUnderline
        disabled={required && selected.length !== amount}
        onClick={confirm}
        css={styles.confirm}
      >
        {confirmLabel(selected)}
      </ButtonUnderline>
      {' '}
    </div>
  )
}

function stopPropagation(e: React.SyntheticEvent) {
  e.stopPropagation()
}

const styles = {
  container: css({
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'stretch',
    // 1.4: font size of h2, 5px: border width of Dialog
    maxHeight: 'calc(98vh - calc(1.4 * 2.33em) - 5px)',
    paddingBottom: '0.67em',
    overflowX: 'hidden',
    overflowY: 'auto'
  }),

  block: css({
    padding: '0.33em 1.33em'
  }),

  blockLabel: css({
    fontSize: '1.1em',
    marginBottom: '0.33em'
  }),

  confirm: css({
    alignSelf: 'center',
    marginTop: '1em'
  })
}
