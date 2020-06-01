export interface User {
  readonly id: string
  readonly token: string
  readonly name: string
}

export namespace User {
  export const empty: User = {
    id: '',
    token: '',
    name: ''
  }
}
