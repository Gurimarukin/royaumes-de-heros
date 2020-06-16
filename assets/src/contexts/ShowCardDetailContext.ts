import { createContext } from 'react'

export const ShowCardDetailContext = createContext<(key: string) => void>(() => {})
