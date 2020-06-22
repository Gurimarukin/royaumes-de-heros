/** @jsx jsx */
import { jsx, css } from '@emotion/core'
import { FunctionComponent } from 'react'

import { Lobby } from '../../models/lobby/Lobby'
import { pipe, List, Maybe } from '../../utils/fp'

interface Props {
  readonly lobby: Lobby
}

export const Params: FunctionComponent<Props> = ({ lobby }) => (
  <div css={styles.container}>
    Partie de{' '}
    {pipe(
      lobby.players,
      List.findFirst(([_]) => _ === lobby.owner),
      Maybe.fold(
        () => null,
        ([, _]) => _.name
      )
    )}
    <br />
    <br />
    Deck : base
    <br />
    <br />
    PV : 50
  </div>
)

const styles = {
  container: css({
    height: '100%',
    backgroundColor: 'black',
    borderRight: '1px solid darkgoldenrod',
    fontSize: '1.1em',
    padding: '.33em'
  })
}
