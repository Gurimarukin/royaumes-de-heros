/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useContext } from 'react'

import { UserContext } from '../../contexts/UserContext'
import { Card } from '../../models/game/Card'
import { Game } from '../../models/game/Game'

interface Props {
  readonly call: (msg: any) => void
  readonly card: Card
}

export const CardComponent: FunctionComponent<Props> = ({ call, card }) => {
  const user = useContext(UserContext)

  return (
    <div>
      <pre>{JSON.stringify(card, null, 2)}</pre>
      {/* <button onClick={play}>Jouer</button> */}
    </div>
  )
}
