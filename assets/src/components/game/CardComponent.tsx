/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent, ReactNode, useMemo, useCallback, useState, Fragment } from 'react'
import { animated } from 'react-spring'

import { ClickOutside } from '../ClickOutside'
import { params } from '../../params'
import { WithId } from '../../models/WithId'
import { PushSocket } from '../../models/PushSocket'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'
import { CardData } from '../../utils/CardData'
import { pipe, Maybe, Future } from '../../utils/fp'

interface CommonProps {
  readonly style?: React.CSSProperties
}

type CardProps = {
  readonly call: PushSocket
  readonly showDiscard: (playerId: string) => void
  readonly game: Game
  readonly playerId: string
  readonly card: WithId<Card>
  readonly zone: Zone
} & CommonProps

export type Zone = 'market' | 'hand' | 'fightZone' | 'discard'

type MouseEventHandler<A = HTMLElement> = (e: React.MouseEvent<A>) => void

export const CardComponent: FunctionComponent<CardProps> = ({
  call,
  showDiscard,
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

  const ability = useCallback(
    (key: string, label: string): JSX.Element => (
      <button onClick={callAndRun([`use_${key}_ability`, cardId])}>Capacité {label}</button>
    ),
    [callAndRun, cardId]
  )

  const data = CardData.get(card.key)

  const isOther = game.player[0] !== playerId
  const isCurrent = Game.isCurrentPlayer(game)
  const pendingInteraction = Game.pendingInteraction(game)
  const onClick = useMemo<MouseEventHandler | undefined>(() => {
    switch (zone) {
      case 'market':
        return isCurrent ? callAndRun(['buy_card', cardId]) : undefined

      case 'hand':
        return !isOther && isCurrent ? callAndRun(['play_card', cardId]) : undefined

      case 'fightZone':
        return pipe(
          pendingInteraction,
          Maybe.fold(
            () => {
              if (isCurrent) {
                return isOther
                  ? callAndRun(['attack', playerId, cardId])
                  : pipe(
                      data,
                      Maybe.map(({ expend, ally, sacrifice }) =>
                        expend || ally || sacrifice ? toggleAbilities : undefined
                      ),
                      Maybe.toUndefined
                    )
              }
              return undefined
            },
            interaction =>
              interaction === 'stun_champion' && isOther
                ? callAndRun(['interact', ['stun_champion', playerId, cardId]])
                : interaction === 'prepare_champion' && !isOther
                ? callAndRun(['interact', ['prepare_champion', cardId]])
                : undefined
          )
        )

      case 'discard':
        return () => showDiscard(playerId)
    }
  }, [
    callAndRun,
    cardId,
    data,
    pendingInteraction,
    isCurrent,
    isOther,
    playerId,
    showDiscard,
    toggleAbilities,
    zone
  ])

  return (
    <ClickOutside onClickOutside={closeAbilities}>
      <div onClick={onClick} css={styles.container} style={style}>
        {pipe(
          data,
          Maybe.fold<CardData, ReactNode>(
            () => `carte inconnue: ${card.key}`,
            ({ image, faction, expend, ally, sacrifice }) => {
              const f = Maybe.toUndefined(faction)
              return (
                <Fragment>
                  <img src={image} alt={card.key} />
                  <div css={styles.icons}>
                    {card.expend_ability_used ? icon('/images/expend.png', f) : null}
                    {card.ally_ability_used ? icon(`/images/factions/${f}.png`, f) : null}
                  </div>
                  {abilitiesOpened ? (
                    <div css={styles.abilities}>
                      {expend && !card.expend_ability_used ? ability('expend', 'Activer') : null}
                      {ally && !card.ally_ability_used ? ability('ally', 'Allié') : null}
                      {sacrifice ? ability('sacrifice', 'Sacrifice') : null}
                    </div>
                  ) : null}
                </Fragment>
              )
            }
          )
        )}
      </div>
    </ClickOutside>
  )
}

function icon(src: string, alt?: string): JSX.Element {
  return (
    <div css={styles.icon}>
      <img src={src} alt={alt} />
    </div>
  )
}

export const AnimatedCard = animated(CardComponent)

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
    // willChange: 'left, top',

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
