/** @jsx jsx */
import * as D from 'io-ts/lib/Decoder'
import { jsx } from '@emotion/core'
import { draw } from 'io-ts/lib/Tree'
import { FunctionComponent, useState, useContext, useEffect } from 'react'

import { Router } from './Router'
import { HistoryContext } from '../contexts/HistoryContext'
import { CardDatasContext } from '../contexts/CardDatasContext'
import { UserContext } from '../contexts/UserContext'
import { PartialCardData, CardData } from '../models/game/CardData'
import { User } from '../models/User'
import { pipe, Either } from '../utils/fp'

interface Props {
  readonly user: unknown
  readonly card_data: unknown
}
const cardDatasCodec = D.record(PartialCardData.codec)

export const App: FunctionComponent<Props> = props => {
  const user = pipe(
    props.user,
    User.codec.decode,
    Either.getOrElse<D.DecodeError, User>(e => {
      throw Error(`couldn't decode user:\n${draw(e)}`)
    })
  )

  const cardDatas = pipe(
    props.card_data,
    cardDatasCodec.decode,
    Either.fold(e => {
      throw Error(`couldn't decode cardDatas:\n${draw(e)}`)
    }, CardData.fromPartial)
  )

  const history = useContext(HistoryContext)
  const [path, setPath] = useState(history.location.pathname)
  useEffect(() => {
    history.listen(location => setPath(location.pathname))
  }, [history])

  return (
    <UserContext.Provider value={user}>
      <CardDatasContext.Provider value={cardDatas}>
        <Router path={path} />
      </CardDatasContext.Provider>
    </UserContext.Provider>
  )
}
