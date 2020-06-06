import { Future, Either } from '../utils/fp'

export type PushSocket = (msg: any) => Future<Either<void, void>>
