import { createContext, Dispatch, SetStateAction } from 'react'

import { User } from '../models/User'

interface Context {
  readonly user: User
  readonly setUser: Dispatch<SetStateAction<User>>
}

export const UserContext = createContext<Context>({ user: User.empty, setUser: () => {} })
