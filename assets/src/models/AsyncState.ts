export type AsyncState<E, A> = AsyncState.Loading | AsyncState.Error<E> | AsyncState.Success<A>

export namespace AsyncState {
  export interface Loading {
    readonly _tag: 'Loading'
  }

  export const Loading: AsyncState<never, never> = { _tag: 'Loading' }

  export function isLoading<E, A>(state: AsyncState<E, A>): state is Loading {
    return state._tag === 'Loading'
  }

  export interface Error<E> {
    readonly _tag: 'Error'
    readonly value: E
  }

  export function Error<E>(value: E): AsyncState<E, never> {
    return { _tag: 'Error', value }
  }

  export function isError<E, A>(state: AsyncState<E, A>): state is Error<E> {
    return state._tag === 'Error'
  }

  export interface Success<A> {
    readonly _tag: 'Success'
    readonly value: A
  }

  export function Success<A>(value: A): AsyncState<never, A> {
    return { _tag: 'Success', value }
  }

  export function fold<E, A, B>({
    onLoading,
    onError,
    onSuccess
  }: FoldArgs<E, A, B>): (state: AsyncState<E, A>) => B {
    return state =>
      isLoading(state)
        ? onLoading()
        : isError(state)
        ? onError(state.value)
        : onSuccess(state.value)
  }
}

interface FoldArgs<E, A, B> {
  onLoading: () => B
  onError: (e: E) => B
  onSuccess: (a: A) => B
}
