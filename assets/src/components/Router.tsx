/** @jsx jsx */
import { jsx } from '@emotion/core'
import { useEffect, ReactElement } from 'react'
import { end, lit, zero, type, parse, Route, format } from 'fp-ts-routing'

import { NotFound } from './NotFound'
import { Squad } from './Squad'
import { Home } from './Home'
import { SquadId } from '../models/SquadId'
import { Maybe } from '../utils/fp'

type TitleWithElt = [Maybe<string>, ReactElement]

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

const squadsMatch = end
const squadMatch = lit('game').then(type('id', SquadId.codec))

/* eslint-disable react/jsx-key */
const routes = zero<TitleWithElt>()
  .alt(squadsMatch.parser.map(_ => [Maybe.none, <Home />]))
  .alt(squadMatch.parser.map(({ id }) => [Maybe.none, <Squad id={id} />]))

function route(s: string): TitleWithElt {
  return parse(routes, Route.parse(s), [Maybe.some('Page non trouvée'), <NotFound />])
}
/* eslint-enable react/jsx-key */

export namespace Router {
  export const routes = {
    squads: format(squadsMatch.formatter, {}),
    squad: (id: SquadId): string => format(squadMatch.formatter, { id })
  }
}
