/** @jsx jsx */
import * as t from 'io-ts'
import { jsx } from '@emotion/core'
import { Socket, Channel } from 'phoenix'
import { Dispatch, SetStateAction, FunctionComponent, useState } from 'react'
import { failure } from 'io-ts/lib/PathReporter'

import { Squad } from '../models/Squad'
import { pipe, Either } from '../utils/fp'

export const App: FunctionComponent = () => {
  const [squads, setSquads] = useState<Squad[]>([])

  const [[_socket, channel]] = useState(() => connectSquadsSocket(setSquads))

  return (
    <div>
      <button onClick={createGame(channel)}>Nouvelle partie</button>

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
}

function connectSquadsSocket(setSquads: Dispatch<SetStateAction<Squad[]>>): [Socket, Channel] {
  const socket = new Socket('/socket' /*{ params: { token: window.userToken } }*/)
  socket.connect()

  const channel = socket.channel('squads')

  channel
    .join()
    .receive('ok', decodePayload(setSquads))
    .receive('error', resp => console.log('error:', resp))

  channel.on('update', decodePayload(setSquads))

  return [socket, channel]
}

function createGame(channel: Channel): () => void {
  return () => {
    channel.push('create', {})
  }
}

const payloadCodec = t.strict({ body: t.array(Squad.codec) })

function decodePayload(f: (squads: Squad[]) => void): (resp: any) => void {
  return resp => {
    console.log('ok:', resp)
    pipe(
      resp,
      payloadCodec.decode,
      Either.fold(
        e => console.error("Couldn't decode response:", failure(e)),
        payload => f(payload.body)
      )
    )
  }
}
