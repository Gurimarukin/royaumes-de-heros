/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, useState, useCallback, ReactNode, Fragment } from 'react'

import { SimpleCard } from './card/SimpleCard'
import { ButtonUnderline } from '../Buttons'
import { WithId } from '../../models/WithId'
import { Card } from '../../models/game/Card'
import { List, pipe, Either } from '../../utils/fp'
import { params } from '../../params'

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
              {blocks.map(([label, c], i) =>
                cards.length === 0 ? null : (
                  <div key={i} css={styles.block}>
                    <div css={styles.blockLabel}>{label}</div>
                    {cards(selected, toggleCard, c)}
                  </div>
                )
              )}
            </Fragment>
          ),
          _ => cards(selected, toggleCard, _)
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

function cards(
  selected: string[],
  toggleCard: (cardId: string) => () => void,
  cards: WithId<Card>[]
): JSX.Element {
  return (
    <div css={styles.cards}>
      {cards.map(([cardId, card], j) => (
        <SimpleCard
          key={j}
          card={Card.reset(card)}
          onClick={toggleCard(cardId)}
          css={styles.card}
          className={
            pipe(
              selected,
              List.exists(_ => _ === cardId)
            )
              ? 'selected'
              : undefined
          }
        />
      ))}
    </div>
  )
}

function stopPropagation(e: React.SyntheticEvent) {
  e.stopPropagation()
}

const scaleCard = 0.7
const styles = {
  container: css({
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'stretch',
    width: 'calc(98vw - 10px)',
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

  cards: css({
    // display: 'flex',
    width: '100%',
    // flexWrap: 'wrap',
    padding: '0 1em'
  }),

  card: css({
    display: 'inline-block',
    position: 'relative',
    width: params.card.width * scaleCard,
    height: params.card.height * scaleCard,
    flexShrink: 0,
    flexBasis: 0,
    flexGrow: 1,
    margin: 'px 1em',
    borderRadius: params.card.borderRadius * scaleCard * 1.2,
    border: '5px solid transparent',
    cursor: 'pointer',
    transition: 'all 0.2s',

    '&.selected': {
      borderColor: 'crimson'
    },

    '& > img': {
      borderRadius: params.card.borderRadius * scaleCard
    }
  }),

  confirm: css({
    alignSelf: 'center',
    marginTop: '1em'
  })
}
