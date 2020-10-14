/** @jsx jsx */
import { jsx } from '@emotion/core'
import * as D from 'io-ts/Decoder'
import { FunctionComponent, useContext, useEffect, useState } from 'react'

import { CardDatasContext } from '../contexts/CardDatasContext'
import { CsrfTokenContext } from '../contexts/CsrfTokenContext'
import { HistoryContext } from '../contexts/HistoryContext'
import { UserContext } from '../contexts/UserContext'
import { CardData, PartialCardData } from '../models/game/CardData'
import { User } from '../models/User'
import { Either, pipe } from '../utils/fp'
import { Router } from './Router'

interface Props {
  readonly user: unknown
  readonly card_data: unknown
  readonly csrf_token: unknown
}
const cardDatasCodec = D.record(PartialCardData.codec)

export const App: FunctionComponent<Props> = props => {
  const [user, setUser] = useState(decode(User.codec, 'user')(props.user))

  const cardDatas = pipe(props.card_data, decode(cardDatasCodec, 'cardDatas'), CardData.fromPartial)

  const csrfToken = decode(D.string, 'csrfToken')(props.csrf_token)

  const history = useContext(HistoryContext)
  const [path, setPath] = useState(history.location.pathname)
  useEffect(() => {
    history.listen(location => setPath(location.pathname))
  }, [history])

  return (
    <UserContext.Provider value={{ user, setUser }}>
      <CardDatasContext.Provider value={cardDatas}>
        <CsrfTokenContext.Provider value={csrfToken}>
          <Router path={path} />
        </CsrfTokenContext.Provider>
      </CardDatasContext.Provider>
    </UserContext.Provider>
  )
}

function decode<A>(codec: D.Decoder<unknown, A>, name: string): (u: unknown) => A {
  return u =>
    pipe(
      u,
      codec.decode,
      Either.getOrElse<D.DecodeError, A>(e => {
        throw Error(`couldn't decode ${name}:\n${D.draw(e)}`)
      })
    )
}
