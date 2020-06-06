import { Referentials } from './models/game/Referentials'

const cardWidth = 298
const cardHeight = 417
const cardMargin = 0.05 * cardWidth
const card = {
  width: cardWidth,
  height: cardHeight,
  widthPlusMargin: cardWidth + cardMargin,
  heightPlusMargin: cardHeight + cardMargin,
  margin: cardMargin,
  borderRadius: 24
}

const fightZoneColumns = 10
const fightZoneInnerWidth = fightZoneColumns * card.widthPlusMargin - card.margin
const fightZoneInnerHeight = 2 * card.heightPlusMargin - card.margin
const fightZoneBorderWidth = 0.05 * card.width
const fightZone = {
  width: fightZoneInnerWidth + 2 * (fightZoneBorderWidth + card.margin),
  height: fightZoneInnerHeight + 2 * (fightZoneBorderWidth + card.margin),
  innerWidth: fightZoneInnerWidth,
  innerHeight: fightZoneInnerHeight,
  columns: fightZoneColumns,
  borderWidth: fightZoneBorderWidth
}

const bottomZone = {
  width: fightZoneInnerWidth,
  height: card.height
}

const playerZone = {
  width: fightZone.width,
  height: fightZone.height + bottomZone.height + 2 * card.margin
}

const marketInnerWidth = card.width
const marketInnerHeight = 6 * card.heightPlusMargin - card.margin
const marketBorderWidth = fightZone.borderWidth
const market = {
  width: marketInnerWidth + 2 * (marketBorderWidth + card.margin),
  height: marketInnerHeight + 2 * (marketBorderWidth + card.margin),
  innerWidth: marketInnerWidth,
  innerHeight: marketInnerHeight,
  borderWidth: marketBorderWidth
}

export const params = {
  board: {
    width: (referentials: Referentials) =>
      market.width +
      Math.ceil((referentials.others.length + 1) / 2) * (playerZone.width + card.margin) +
      2 * card.margin,
    height: 2 * playerZone.height + card.margin
  },
  card,
  playerZone,
  fightZone,
  bottomZone,
  market
}
