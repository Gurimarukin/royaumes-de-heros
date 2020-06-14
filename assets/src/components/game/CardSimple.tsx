/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { ReactNode, Fragment, forwardRef } from 'react'
import { animated } from 'react-spring'

import { AbilityIcon } from './AbilityIcon'
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

const HIDDEN = 'hidden'

export const CardSimple = forwardRef<HTMLDivElement, Props>(
  ({ card, onClick, className, style, children }, ref) => {
    const data = CardData.get(card.key)
    return (
      <div ref={ref} onClick={onClick} css={styles.container} className={className} style={style}>
        {pipe(
          data,
          Maybe.fold<CardData, ReactNode>(
            () => `carte inconnue: ${card.key}`,
            ({ image, faction }) => (
              <Fragment>
                <img src={image} alt={card.key} />
                <div css={styles.icons}>
                  <AbilityIcon
                    icon='expend'
                    crossedOut={true}
                    css={styles.icon}
                    className={card.expend_ability_used ? undefined : HIDDEN}
                  />
                  {pipe(
                    faction,
                    Maybe.fold(
                      () => null,
                      f => (
                        <AbilityIcon
                          icon={f}
                          crossedOut={true}
                          css={styles.icon}
                          className={card.ally_ability_used ? undefined : HIDDEN}
                        />
                      )
                    )
                  )}
                </div>
              </Fragment>
            )
          )
        )}
        {children}
      </div>
    )
  }
)

export const AnimatedSimpleCard = animated(CardSimple)

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
    margin: '0 0.2em',
    transition: 'all 0.2s',

    [`&.${HIDDEN}`]: {
      opacity: 0,
      display: 'none'
    }
  })
}
