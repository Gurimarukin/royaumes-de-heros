import { Future, Either } from '../../utils/fp'

export type CallGame = (msg: any) => Future<Either<void, void>>
