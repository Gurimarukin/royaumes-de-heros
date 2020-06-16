/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { ReactNode, Fragment, forwardRef, useContext } from 'react'

import { params } from '../../params'
import { CardDatasContext } from '../../contexts/CardDatasContext'
import { Card } from '../../models/game/Card'
import { CardData } from '../../models/game/CardData'
import { pipe, Maybe, Dict } from '../../utils/fp'

interface Props {
  readonly card: Card
  readonly onClick?: React.MouseEventHandler<HTMLDivElement>
  readonly onContextMenu?: React.MouseEventHandler<HTMLDivElement>
  readonly className?: string
  readonly style?: React.CSSProperties
  readonly children?: (d: CardData) => ReactNode
}

export const CardSimple = forwardRef<HTMLDivElement, Props>(
  ({ card, onClick, onContextMenu, className, style, children }, ref) => {
    const data = Dict.lookup(card.key, useContext(CardDatasContext))

    return (
      <div
        ref={ref}
        onClick={onClick}
        onContextMenu={onContextMenu}
        css={styles.container}
        className={className}
        style={style}
      >
        {pipe(
          data,
          Maybe.fold<CardData, ReactNode>(
            () => `carte inconnue: ${card.key}`,
            d => (
              <Fragment>
                <img src={d.image} alt={card.key} />
                {children === undefined ? null : children(d)}
              </Fragment>
            )
          )
        )}
      </div>
    )
  }
)

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
  })
}
