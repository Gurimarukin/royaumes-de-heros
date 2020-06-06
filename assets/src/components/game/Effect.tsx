/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, Fragment } from 'react'

import { Effect as TEffect } from '../../models/game/Effect'
import { Coin, Potion, Swords } from '../icons'

interface Props {
  readonly effect: TEffect
  readonly championsInFightZone: number
}

export const Effect: FunctionComponent<Props> = ({ effect, championsInFightZone }) => {
  const [icon, value] = iconAndValue(effect, championsInFightZone)
  return (
    <Fragment>
      {icon} {value}
    </Fragment>
  )
}

function iconAndValue(effect: TEffect, championsInFightZone: number): [JSX.Element, number] {
  switch (effect[0]) {
    /* eslint-disable react/jsx-key */
    case 'add_combat':
      return [<Swords css={styles.combat} />, effect[1]]

    case 'add_gold':
      return [<Coin css={styles.gold} />, effect[1]]

    case 'heal':
      return [<Potion css={styles.heal} />, effect[1]]

    case 'heal_for_champions':
      const [base, perChampion] = effect[1]
      return [<Potion css={styles.heal} />, base + perChampion * championsInFightZone]
    /* eslint-enable react/jsx-key */
  }
}

const styles = {
  combat: css({
    color: 'crimson',
    transform: 'rotate(180deg)'
  }),

  gold: css({
    color: 'gold'
  }),

  heal: css({
    color: '#76b763'
  })
}
