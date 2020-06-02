import * as D from 'io-ts/lib/Decoder'

import { Card } from './Card'
import { OtherPlayer } from './OtherPlayer'
import { Player } from './Player'
import { WithId } from '../WithId'
// import { Either, pipe } from '../../utils/fp'

// const eitherPlayer: D.Decoder<Either<OtherPlayer, Player>> = {
//   decode: (u: unknown) =>
//     pipe(
//       Player.codec.decode(u),
//       Either.map(_ => Either.right<OtherPlayer, Player>(_)),
//       Either.alt(() =>
//         pipe(
//           OtherPlayer.codec.decode(u),
//           Either.map(_ => Either.left<OtherPlayer, Player>(_))
//         )
//       )
//     )
// }

export namespace Game {
  export const codec = D.type({
    player: WithId.codec(Player.codec),
    other_players: D.array(WithId.codec(OtherPlayer.codec)),
    current_player: D.string,
    gems: D.number,
    market: D.array(WithId.codec(Card.codec)),
    market_deck: D.number,
    cemetery: D.array(WithId.codec(Card.codec))
  })
}

export type Game = D.TypeOf<typeof Game.codec>
