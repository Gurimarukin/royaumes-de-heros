import { createContext } from 'react'

import { CardData } from '../models/game/CardData'
import { Dict } from '../utils/fp'

export const CardDatasContext = createContext<Dict<CardData>>({})
