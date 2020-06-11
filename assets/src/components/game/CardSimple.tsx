/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { ReactNode, Fragment, forwardRef } from 'react'
import { animated } from 'react-spring'

import { Card } from '../../models/game/Card'
import { CardData } from '../../utils/CardData'
import { pipe, Maybe } from '../../utils/fp'
import { params } from '../../params'

interface Props {
  readonly card: Card
  readonly onClick?: React.MouseEventHandler<HTMLDivElement>
  readonly className?: string
  readonly style?: React.CSSProperties
  readonly children?: ReactNode
}

export const CardSimple = forwardRef<HTMLDivElement, Props>(
  ({ card, onClick, className, style, children }, ref) => {
    const data = CardData.get(card.key)
    return (
      <div ref={ref} onClick={onClick} css={styles.container} className={className} style={style}>
        {pipe(
          data,
          Maybe.fold<CardData, ReactNode>(
            () => `carte inconnue: ${card.key}`,
            ({ image, faction }) => {
              const f = Maybe.toUndefined(faction)
              return (
                <Fragment>
                  <img src={image} alt={card.key} />
                  <div css={styles.icons}>
                    {card.expend_ability_used ? icon('/images/expend.png', f) : null}
                    {card.ally_ability_used ? icon(`/images/factions/${f}.png`, f) : null}
                  </div>
                </Fragment>
              )
            }
          )
        )}
        {children}
      </div>
    )
  }
)

export const AnimatedSimpleCard = animated(CardSimple)

function icon(src: string, alt?: string): JSX.Element {
  return (
    <div css={styles.icon}>
      <img src={src} alt={alt} />
    </div>
  )
}

const styles = {
  container: css({
    width: params.card.width,
    height: params.card.height,

    '& > img': {
      width: '100%',
      height: '100%',
      borderRadius: params.card.borderRadius,
      boxShadow: '0 0 4px black'
    }
  }),

  icons: css({
    position: 'absolute',
    left: 0,
    bottom: '-12px',
    width: '100%',
    display: 'flex',
    justifyContent: 'center'
  }),

  icon: css({
    position: 'relative',
    width: '40px',
    height: '40px',
    border: '4px solid crimson',
    borderRadius: '50%',
    boxShadow: '0 0 4px black',
    overflow: 'hidden',
    margin: '0 0.12em',

    '&::after': {
      content: `''`,
      position: 'absolute',
      left: 0,
      top: '14px',
      width: '100%',
      borderTop: '4px solid crimson',
      transform: 'rotate(-45deg)'
    },

    '& > img': {
      width: '44px',
      height: '44px',
      margin: '-5px'
    }
  })
}
