/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useState, useContext, useEffect } from 'react'

import { Router } from './Router'
import { HistoryContext } from '../contexts/HistoryContext'

export const App: FunctionComponent = () => {
  const history = useContext(HistoryContext)
  const [path, setPath] = useState(history.location.pathname)
  useEffect(() => {
    history.listen(location => setPath(location.pathname))
  }, [history])

  return <Router path={path} />
}
