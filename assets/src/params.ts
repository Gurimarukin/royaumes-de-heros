import { Referentials } from './models/game/Referentials'

const cardWidth = 298
const cardMargin = 0.06 * cardWidth
const card = {
  width: cardWidth,
  height: 417,
  margin: cardMargin,
  borderRadius: 24
}

const fightZone = {
  width: 9 * card.width,
  height: 2 * card.height,
  borderWidth: 0.05 * card.width
}

const playerZone = {
  width: fightZone.width,
  height: fightZone.height + card.height
}

const marketPadding = cardMargin
const marketBorderWidth = fightZone.borderWidth
const market = {
  width: card.width + 2 * (marketBorderWidth + marketPadding),
  height: card.height * 6 + 2 * (marketBorderWidth + marketPadding) + 5 * card.margin,
  borderWidth: marketBorderWidth,
  padding: marketPadding
}

export const params = {
  board: (referentials: Referentials) => ({
    width: market.width + playerZone.width * Math.ceil((referentials.others.length + 1) / 2),
    height: market.height
  }),

  card,

  playerZone,

  fightZone,

  market
}
