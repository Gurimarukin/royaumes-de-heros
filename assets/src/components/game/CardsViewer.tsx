/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { CardSimple } from './CardSimple'
import { params } from '../../params'
import { Card } from '../../models/game/Card'
import { CardId } from '../../models/game/CardId'
import { pipe, List } from '../../utils/fp'

interface Props {
  readonly cards: [CardId, Card][]
  readonly selected?: CardId[]
  readonly toggleCard?: (id: CardId) => () => void
}

const SELECTED = 'selected'

export const CardsViewer: FunctionComponent<Props> = ({ selected = [], toggleCard, cards }) => (
  <div css={styles.cards}>
    {cards.map(([id, card], j) => (
      <CardSimple
        key={j}
        card={Card.reset(card)}
        onClick={toggleCard === undefined ? undefined : toggleCard(id)}
        css={styles.card}
        className={
          pipe(
            selected,
            List.exists(_ => _ === id)
          )
            ? SELECTED
            : undefined
        }
        style={{ cursor: toggleCard === undefined ? undefined : 'pointer' }}
      />
    ))}
  </div>
)

const scaleCard = 0.7
const styles = {
  cards: css({
    width: '100%',
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
    transition: 'all 0.2s',

    [`&.${SELECTED}`]: {
      borderColor: 'crimson'
    },

    '& > img': {
      borderRadius: params.card.borderRadius * scaleCard
    }
  })
}
