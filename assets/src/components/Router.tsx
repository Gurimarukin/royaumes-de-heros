/** @jsx jsx */
import { jsx } from '@emotion/core'
import { parser as P, string as S, char as C } from 'parser-ts'
import { run } from 'parser-ts/lib/code-frame'
import { useEffect, ReactElement } from 'react'

import { NotFound } from './NotFound'
import { Squads } from './Squads'
import { Maybe, pipe, List } from '../utils/fp'
import { Squad } from './Squad'

type Route = (path: string) => Maybe<SubtitleWithElt>
type SubtitleWithElt = [Maybe<string>, ReactElement]

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

/* eslint-disable react/jsx-key */
function route(path: string): SubtitleWithElt {
  return pipe(
    [
      exactMatcher(routes.squads)(() => [Maybe.none, <Squads />]),
      simpleExtractor('game')(id => [Maybe.none, <Squad id={id} />])
    ],
    List.reduce<Route, Maybe<SubtitleWithElt>>(Maybe.none, (acc, route) =>
      pipe(
        acc,
        Maybe.alt(() => route(path))
      )
    ),
    Maybe.getOrElse(() => [Maybe.some('Page non trouvée'), <NotFound />])
  )
}
/* eslint-enable react/jsx-key */

function exactMatcher(str: string): (f: () => SubtitleWithElt) => Route {
  return f => path =>
    pipe(
      str === path ? Maybe.some(path) : Maybe.none,
      Maybe.map(_ => f())
    )
}

const alphanum = S.many(C.alphanum)

// matches "/prefix/:param"
function simpleExtractor(prefix: string): (f: (a: string) => SubtitleWithElt) => Route
function simpleExtractor<A>(
  prefix: string,
  argParser: P.Parser<string, A>
): (f: (a: A) => SubtitleWithElt) => Route
function simpleExtractor<A>(
  prefix: string,
  argParser: P.Parser<string, A> = (alphanum as unknown) as P.Parser<string, A>
): (f: (a: A) => SubtitleWithElt) => Route {
  const parser = pipe(
    S.string(`/${prefix}/`),
    P.chain(_ => argParser),
    P.chain(res =>
      pipe(
        P.eof<string>(),
        P.map(_ => res)
      )
    )
  )
  return f => path => pipe(run(parser, path), Maybe.fromEither, Maybe.map(f))
}
