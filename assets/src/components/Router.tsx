/** @jsx jsx */
import { jsx } from '@emotion/core'
import { FunctionComponent, useEffect, ReactElement } from 'react'

import { NotFound } from './NotFound'
import { Squads } from './Squads'
import { Maybe, pipe, Dict } from '../utils/fp'

interface Props {
  readonly path: string
}

export function Router({ path }: Props): ReactElement {
  const [subTitle, node] = route(path)
  const title = ['Royaume de Héros', ...Maybe.toArray(subTitle)].join('|')

  useEffect(() => {
    document.title = title
  }, [title])

  return node
}

export namespace Router {
  export const routes = {
    squads: '/',
    squad: (id: string): string => `/game/${id}`
  }
}

const routes = Router.routes

function route(path: string): [Maybe<string>, ReactElement] {
  return pipe(
    Dict.lookup<[Maybe<string>, ReactElement]>(path, {
      [routes.squads]: [Maybe.none, <Squads />]
    }),
    Maybe.getOrElse(() => [Maybe.some('Page non trouvée'), <NotFound />])
  )
}
