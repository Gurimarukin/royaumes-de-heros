/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, ReactNode, useMemo, useCallback, useState, Fragment } from 'react'
import { animated } from 'react-spring'

import { params } from '../../params'
import { useClickOutside } from '../../hooks/useClickOutside'
import { WithId } from '../../models/WithId'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'
import { CardData } from '../../utils/CardData'
import { pipe, Maybe, Future, Either } from '../../utils/fp'

interface CommonProps {
  readonly style?: React.CSSProperties
}

type CardProps = {
  readonly call: (msg: any) => Future<Either<void, void>>
  readonly game: Game
  readonly playerId: string
  readonly card: WithId<Card>
  readonly zone: Zone
} & CommonProps

export type Zone = 'market' | 'hand' | 'fightZone' | 'discard'

type MouseEventHandler<A = HTMLElement> = (e: React.MouseEvent<A>) => void

export const CardComponent: FunctionComponent<CardProps> = ({
  call,
  game,
  playerId,
  card: [cardId, card],
  zone: zone,
  style
}) => {
  const callAndRun = useCallback((msg: any) => () => pipe(call(msg), Future.runUnsafe), [call])

  const [abilitiesOpened, setAbilitiesOpened] = useState(false)
  const closeAbilities = useCallback(() => setAbilitiesOpened(false), [])
  const toggleAbilities = useCallback(() => setAbilitiesOpened(_ => !_), [])

  const clickOutSideRef = useClickOutside<HTMLDivElement>(closeAbilities)

  const ability = useCallback(
    (key: string, label: string): JSX.Element => (
      <button onClick={callAndRun([`use_${key}_ability`, cardId])}>Capacité {label}</button>
    ),
    [callAndRun, cardId]
  )

  const data = CardData.get(card.key)

  const isOther = game.player[0] !== playerId
  const isCurrent = Game.isCurrentPlayer(game)
  const onClick = useMemo<MouseEventHandler | undefined>(() => {
    switch (zone) {
      case 'market':
        return isCurrent ? callAndRun(['buy_card', cardId]) : undefined

      case 'hand':
        return !isOther && isCurrent ? callAndRun(['play_card', cardId]) : undefined

      case 'fightZone':
        return isCurrent
          ? isOther
            ? callAndRun(['attack', playerId, cardId])
            : pipe(
                data,
                Maybe.map(({ expend, ally, sacrifice }) =>
                  expend || ally || sacrifice ? toggleAbilities : undefined
                ),
                Maybe.toUndefined
              )
          : undefined

      case 'discard':
        // TODO: show discard
        return undefined
    }
  }, [callAndRun, cardId, data, isCurrent, isOther, toggleAbilities, playerId, zone])

  return (
    <div ref={clickOutSideRef} onClick={onClick} css={styles.container} style={style}>
      {pipe(
        data,
        Maybe.fold<CardData, ReactNode>(
          () => `carte inconnue: ${card.key}`,
          ({ image, expend, ally, sacrifice }) => (
            <Fragment>
              <img src={image} />
              {abilitiesOpened ? (
                <div css={styles.abilities}>
                  {expend && !card.expend_ability_used ? ability('expend', 'Activer') : null}
                  {ally && !card.ally_ability_used ? ability('ally', 'Allié') : null}
                  {sacrifice ? ability('sacrifice', 'Sacrifice') : null}
                </div>
              ) : null}
            </Fragment>
          )
        )
      )}
    </div>
  )
}

export const AnimatedCardComponent = animated(CardComponent)

export const HiddenCard: FunctionComponent<CommonProps> = ({ style }) => (
  <div css={styles.container} style={style}>
    <img src={CardData.hidden} />
  </div>
)

const styles = {
  container: css({
    position: 'absolute',
    width: params.card.width,
    height: params.card.height,

    '& > img': {
      width: '100%',
      height: '100%',
      borderRadius: params.card.borderRadius,
      boxShadow: '0 0 4px black'
    }
  }),

  abilities: css({
    position: 'absolute',
    left: 0,
    top: 0,
    width: params.card.width,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',

    '& > button': {
      fontSize: '3em'
    }
  })
}
