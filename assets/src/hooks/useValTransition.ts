import { useTransition, UseTransitionResult, AnimatedValue } from 'react-spring'

export function useValTransition<A extends {}>(
  values: A
): UseTransitionResult<A, AnimatedValue<Pick<A, keyof A>>>[] {
  return useTransition<A, A>(values, null, {
    ...values,
    from: values,
    leave: values,
    update: (_: any) => _
  } as any) as any
}
