/** @jsx jsx */
import * as t from 'io-ts'
import { jsx } from '@emotion/core'
import { Socket } from 'phoenix'
import { FunctionComponent, useEffect, useState } from 'react'
import { failure } from 'io-ts/lib/PathReporter'

import { Squad } from '../models/Squad'
import { pipe, Either } from '../utils/fp'

export const App: FunctionComponent = () => {
  const [squads, setSquads] = useState<Squad[]>([])

  useEffect(() => {
    connectSquadsSocket(setSquads)
  }, [])

  return (
    <div>
      <table>
        <thead>
          <th>
            <td>Phase</td>
            <td>Joueurs</td>
            <td />
          </th>
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
}

function connectSquadsSocket(onOk: (state: Squad[]) => void) {
  const socket = new Socket('/socket' /*{ params: { token: window.userToken } }*/)
  socket.connect()

  const channel = socket.channel('squads')

  channel
    .join()
    .receive('ok', resp => {
      console.log('Joined successfully', resp)
      pipe(
        resp,
        t.array(Squad.codec).decode,
        Either.fold(e => console.log("Couldn't decode response:", failure(e)), onOk)
      )
    })
    .receive('error', resp => console.log('Unable to join', resp))
}
