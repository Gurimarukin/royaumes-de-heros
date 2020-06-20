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
    minHeight: '50%',
    backgroundImage: "url('/images/sandstone_top.png')",
    color: 'black',
    border: '3px solid darkgoldenrod',
    borderWidth: '0 3px 3px 0',
    fontSize: '1.1em',
    padding: '.33em'
  })
}
