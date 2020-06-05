/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Game } from '../../models/game/Game'
import { pipe, List, Future, Either, Maybe } from '../../utils/fp'

interface Props {
  readonly call: (msg: any) => Future<Either<void, void>>
  readonly game: Game
}

export const PendingInteractions: FunctionComponent<Props> = ({ call, game }) => {
  const [, player] = game.player
  const opened = player.pending_interactions.length !== 0
  console.log('opened =', opened)

  return (
    <div css={styles.container} className={opened ? 'opened' : undefined}>
      {pipe(
        List.head(player.pending_interactions),
        Maybe.fold(
          () => null,
          interaction => {
            console.log('interaction =', interaction)
            return JSON.stringify(interaction)
          }
        )
      )}
    </div>
  )
}

const styles = {
  container: css({
    position: 'absolute',
    left: '5%',
    top: '-67%',
    width: '90%',
    height: '67%',
    backgroundColor: 'rgba(0, 0, 0, 0.9)',
    border: '3px double goldenrod',
    borderTop: 0,

    '&.opened': {
      top: '0vh'
    }
  })
}
