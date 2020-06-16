/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { ReactNode, Fragment, forwardRef } from 'react'

import { AbilityIcon } from './AbilityIcon'
import { CardSimple } from './CardSimple'
import { Card } from '../../models/game/Card'
import { pipe, Maybe } from '../../utils/fp'

interface Props {
  readonly card: Card
  readonly onClick?: React.MouseEventHandler<HTMLDivElement>
  readonly onContextMenu?: React.MouseEventHandler<HTMLDivElement>
  readonly className?: string
  readonly style?: React.CSSProperties
  readonly children?: ReactNode
}

const HIDDEN = 'hidden'

export const CardSimpleWithIcons = forwardRef<HTMLDivElement, Props>(
  ({ card, onClick, onContextMenu, className, style, children }, ref) => (
    <CardSimple
      ref={ref}
      card={card}
      onClick={onClick}
      onContextMenu={onContextMenu}
      className={className}
      style={style}
    >
      {({ faction }) => (
        <Fragment>
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
          {children}
        </Fragment>
      )}
    </CardSimple>
  )
)

const styles = {
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
