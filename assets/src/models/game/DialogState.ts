import { Functor1 } from 'fp-ts/lib/Functor'
import { pipeable } from 'fp-ts/lib/pipeable'

declare module 'fp-ts/lib/HKT' {
  interface URItoKind<A> {
    readonly DialogState: DialogState<A>
  }
}

const URI = 'DialogState'
type URI = typeof URI

export type DialogState<A> = DialogState.Interaction<A> | DialogState.Other<A>

export namespace DialogState {
  export const dialogState: Functor1<URI> = {
    URI,
    map: <A, B>(state: DialogState<A>, f: (props: A) => B): DialogState<B> => ({
      _tag: state._tag,
      props: f(state.props)
    })
  }

  export const { map } = pipeable(dialogState)

  // types
  export interface Interaction<A> {
    readonly _tag: 'Interaction'
    readonly props: A
  }

  export function Interaction<A>(props: A): Interaction<A> {
    return { _tag: 'Interaction', props }
  }

  export function isInteraction<A>(state: DialogState<A>): state is Interaction<A> {
    return state._tag === 'Interaction'
  }

  export interface Other<A> {
    readonly _tag: 'Other'
    readonly props: A
  }

  export function Other<A>(props: A): Other<A> {
    return { _tag: 'Other', props }
  }

  // helpers
  export function empty<A>(props: A): DialogState<A> {
    return Other(props)
  }
}
