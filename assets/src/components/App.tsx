/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext, useEffect } from 'react'

import { Router } from './Router'
import { HistoryContext } from '../contexts/HistoryContext'
import { UserContext } from '../contexts/UserContext'
import { User } from '../models/User'

interface Props {
  readonly user: User
}

export const App: FunctionComponent<Props> = ({ user }) => {
  const history = useContext(HistoryContext)
  const [path, setPath] = useState(history.location.pathname)
  useEffect(() => {
    history.listen(location => setPath(location.pathname))
  }, [history])

  return (
    <UserContext.Provider value={user}>
      <Router path={path} />
    </UserContext.Provider>
  )
}
