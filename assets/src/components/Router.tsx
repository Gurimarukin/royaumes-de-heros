/** @jsx jsx */
import { jsx } from '@emotion/core'
import { Formatter, Match, Parser, Route, end, format, lit, parse, zero } from 'fp-ts-routing'
import { tuple } from 'fp-ts/function'
import * as C from 'io-ts/Codec'
import { ReactElement, useEffect } from 'react'

import { SquadId } from '../models/SquadId'
import { Dict, Maybe } from '../utils/fp'
import { Home } from './Home'
import { NotFound } from './NotFound'
import { Squad } from './Squad'

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

const homeMatch = end
const squadMatch = lit('game').then(codec('id', SquadId.codec))

/* eslint-disable react/jsx-key */
const routes = zero<TitleWithElt>()
  .alt(homeMatch.parser.map(_ => [Maybe.none, <Home />]))
  .alt(squadMatch.parser.map(({ id }) => [Maybe.none, <Squad id={id} />]))

function route(s: string): TitleWithElt {
  return parse(routes, Route.parse(s), [Maybe.some('Page non trouvée'), <NotFound />])
}
/* eslint-enable react/jsx-key */

export namespace Router {
  export const routes = {
    home: format(homeMatch.formatter, {}),
    squad: (id: SquadId): string => format(squadMatch.formatter, { id })
  }
}

function codec<K extends string, A>(
  k: K,
  codec: C.Codec<unknown, string, A>
): Match<{ readonly [_ in K]: A }> {
  return new Match(
    new Parser(r =>
      r.parts.length === 0
        ? Maybe.none
        : (() => {
            const head = r.parts[0]
            const tail = r.parts.slice(1)
            return Maybe.option.map(Maybe.fromEither(codec.decode(head)), a =>
              tuple(Dict.singleton(k, a), new Route(tail, r.query))
            )
          })()
    ),
    new Formatter((r, o) => new Route(r.parts.concat(codec.encode(o[k])), r.query))
  )
}
