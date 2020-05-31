/** @jsx jsx */
import * as t from 'io-ts'
import { jsx } from '@emotion/core'
import { Socket, Channel } from 'phoenix'
import { useContext, FunctionComponent, useState } from 'react'

import { HistoryContext } from '../contexts/HistoryContext'
import { Squad } from '../models/Squad'
import { pipe, Either, Future } from '../utils/fp'
import { PhoenixUtils } from '../utils/PhoenixUtils'
import { Router } from './Router'

export const Squads: FunctionComponent = () => {
  const history = useContext(HistoryContext)

  const [squads, setSquads] = useState<Squad[]>([])
  const [[, channel]] = useState(squadsSocketAndChan)

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

  function squadsSocketAndChan(): [Socket, Channel] {
    const socket = new Socket('/socket' /*{ params: { token: window.userToken } }*/)
    socket.connect()

    const channel = socket.channel('squads')

    channel
      .join()
      .receive('ok', onPayload)
      .receive('error', resp => console.log('error:', resp))

    channel.on('update', onPayload)

    return [socket, channel]
  }

  function onPayload(u: unknown): void {
    const { body } = u as any
    return setSquads(body)
  }

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

// const payloadCodec = t.strict({ body: t.array(Squad.codec) })

// function decodePayload(f: (squads: Squad[]) => void): (resp: any) => void {
//   return resp => {
//     console.log('ok:', resp)
//     pipe(
//       resp,
//       payloadCodec.decode,
//       Either.fold(
//         e => console.error("Couldn't decode response:", failure(e)),
//         payload => f(payload.body)
//       )
//     )
//   }
// }
