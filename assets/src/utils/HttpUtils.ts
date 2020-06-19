import { Future, Dict } from './fp'

export namespace HttpUtils {
  export const post = (csrfToken: string) => (
    url: string,
    data: unknown,
    headers: Dict<string> = {}
  ): Future<Response> =>
    Future.apply(() =>
      fetch(url, {
        method: 'POST',
        headers: {
          'X-Csrf-Token': csrfToken,
          'Content-Type': 'application/json',
          ...headers
        },
        body: JSON.stringify(data)
      })
    )
}
