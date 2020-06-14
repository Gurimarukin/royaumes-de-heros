/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Faction } from '../../utils/CardData'
import { Maybe, List } from '../../utils/fp'

interface Props {
  readonly icon: AbilityIcon
  readonly crossedOut?: boolean
  readonly className?: string
}

export type AbilityIcon = Faction | 'expend' | 'sacrifice'

const CROSSED = 'crossed'

export const AbilityIcon: FunctionComponent<Props> = ({ icon, crossedOut = false, className }) => {
  const src =
    icon === 'expend'
      ? '/images/expend.png'
      : icon === 'sacrifice'
      ? '/images/sacrifice.png'
      : `/images/factions/${icon}.png`

  const classes = List.compact([
    crossedOut ? Maybe.some(CROSSED) : Maybe.none,
    Maybe.fromNullable(className)
  ]).join(' ')

  return (
    <div css={styles.icon} className={classes} style={{ borderColor: crossedOut ? '' : '' }}>
      <img src={src} alt={icon} css={styles.image} />
      {crossedOut ? <div css={styles.crossedOut} /> : undefined}
    </div>
  )
}

const styles = {
  icon: css({
    position: 'relative',
    width: '40px',
    height: '40px',
    border: '4px solid dimgrey',
    borderRadius: '50%',
    boxShadow: '0 0 4px black',
    overflow: 'hidden',

    [`&.${CROSSED}`]: {
      borderColor: 'crimson'
    }
  }),

  image: css({
    width: '44px',
    height: '44px',
    margin: '-6px'
  }),

  crossedOut: css({
    position: 'absolute',
    left: 0,
    top: '14px',
    width: '100%',
    borderTop: '4px solid crimson',
    transform: 'rotate(-45deg)'
  })
}
