import { Push } from 'phoenix'

import { Future } from './fp'

export namespace PhoenixUtils {
  export function toFuture(push: Push): Future<any> {
    return Future.apply(
      () => new Promise((resolve, reject) => push.receive('ok', resolve).receive('error', reject))
    )
  }
}
