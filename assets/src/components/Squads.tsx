/** @jsx jsx */
import * as t from 'io-ts'
import { jsx } from '@emotion/core'
import { useContext, FunctionComponent, useState } from 'react'

import { HistoryContext } from '../contexts/HistoryContext'
import { Squad } from '../models/Squad'
import { pipe, Future } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'
import { Router } from './Router'

export const Squads: FunctionComponent = () => {
  const history = useContext(HistoryContext)

  const [squads, setSquads] = useState<Squad[]>([])
  const [[, channel]] = useState(() => PhoenixUtils.initSocket(setSquads, t.array(Squad.codec)))

  return (
    <div>
      <button onClick={createGame()}>Nouvelle partie</button>

      <table>
        <thead>
          <tr>
            <th>Phase</th>
            <th>Joueurs</th>
            <th />
          </tr>
        </thead>
        <tbody>
          {squads.map(squad => (
            <tr key={squad.id}>
              <td>{squad.stage}</td>
              <td>{squad.n_players}</td>
              <td>{squad.stage === 'lobby' ? <button>Rejoindre {squad.id}</button> : null}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )

  function createGame(): () => void {
    return () => {
      pipe(
        channel.push('create', {}),
        PhoenixUtils.toFuture,
        Future.map(({ id }) => history.push(Router.routes.squad(id))),
        Future.runUnsafe
      )
    }
  }
}
