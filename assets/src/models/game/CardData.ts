import * as D from 'io-ts/Decoder'

import { Dict, Maybe, pipe } from '../../utils/fp'
import { Card } from './Card'
import { CardId } from './CardId'

export namespace CardType {
  export const codec = D.union(
    D.literal('item'),
    D.literal('action'),
    D.tuple(D.union(D.literal('not_guard'), D.literal('guard')), D.number),
  )

  export function isChampion(type: CardType): type is ['not_guard' | 'guard', number] {
    return Array.isArray(type)
  }

  export function isGuard(type: CardType): type is ['guard', number] {
    return isChampion(type) && type[0] === 'guard'
  }
}

export type CardType = D.TypeOf<typeof CardType.codec>

export namespace Faction {
  export const codec = D.union(
    D.literal('guild'),
    D.literal('imperial'),
    D.literal('necros'),
    D.literal('wild'),
  )
}

export type Faction = D.TypeOf<typeof Faction.codec>

export namespace PartialCardData {
  export const codec = D.type({
    cost: Maybe.codec(D.number),
    type: CardType.codec,
    faction: Maybe.codec(Faction.codec),
    expend: D.boolean,
    ally: D.boolean,
    sacrifice: D.boolean,
  })
}

export type PartialCardData = D.TypeOf<typeof PartialCardData.codec>

interface NameAndImage {
  readonly name: string
  readonly image: string
}

export type CardData = PartialCardData & NameAndImage

export namespace CardData {
  export function fromPartial(rec: Dict<PartialCardData>): Dict<CardData> {
    return pipe(
      rec,
      Dict.filterMapWithIndex((key, partial) =>
        pipe(
          nameAndImage(key),
          Maybe.fold(
            () => {
              console.warn(`NameAndImage not found for card: "${key}"`)
              return Maybe.none
            },
            _ => Maybe.some({ ...partial, ..._ }),
          ),
        ),
      ),
    )
  }

  export const hidden = '/images/cards/hidden.jpg'

  export function nameAndImage(key: string): Maybe<NameAndImage> {
    return Dict.lookup(key, namesAndImages)
  }

  export function countFaction(
    cardDatas: Dict<CardData>,
    cards: [CardId, Card][],
    faction: Faction,
  ): number {
    return cards.filter(([, c]) =>
      pipe(
        Dict.lookup(c.key, cardDatas),
        Maybe.chain(_ => _.faction),
        Maybe.exists(_ => _ === faction),
      ),
    ).length
  }

  export function countGuards(cardDatas: Dict<CardData>, cards: [CardId, Card][]): number {
    return cards.filter(([, c]) =>
      pipe(
        Dict.lookup(c.key, cardDatas),
        Maybe.exists(_ => CardType.isGuard(_.type)),
      ),
    ).length
  }
}

function d(name: string, image: string): NameAndImage {
  return { name, image }
}

const namesAndImages: Dict<NameAndImage> = {
  /* eslint-disable @typescript-eslint/camelcase */
  shortsword: d('Épée courte', '/images/cards/shortsword.jpg'),
  dagger: d('Dague', '/images/cards/dagger.jpg'),
  ruby: d('Rubis', '/images/cards/ruby.jpg'),
  gold: d('Or', '/images/cards/gold.jpg'),
  gem: d('Gemme de feu', '/images/cards/gem.jpg'),

  // Guild

  borg: d('Borg, Mercenaire Ogre', '/images/cards/borg.jpg'),
  bribe: d('Pot-de-Vin', '/images/cards/bribe.jpg'),
  death_threat: d('Menace de Mort', '/images/cards/death_threat.jpg'),
  deception: d('Fourberie', '/images/cards/deception.jpg'),
  fire_bomb: d('Bombe Incendiaire', '/images/cards/fire_bomb.jpg'),
  hit_job: d('Mise à prix', '/images/cards/hit_job.jpg'),
  intimidation: d('Intimidation', '/images/cards/intimidation.jpg'),
  myros: d('Myros, Mage de la Guilde', '/images/cards/myros.jpg'),
  parov: d("Parov, l'Exécuteur", '/images/cards/parov.jpg'),
  profit: d('Bénéfice', '/images/cards/profit.jpg'),
  rake: d('Rake, Maître Assassin', '/images/cards/rake.jpg'),
  rasmus: d('Rasmus, le Contrebandier', '/images/cards/rasmus.jpg'),
  smash_and_grab: d('Casser et Piller', '/images/cards/smash_and_grab.jpg'),
  street_thug: d('Bandit des Rues', '/images/cards/street_thug.jpg'),

  // Imperial

  arkus: d('Arkus, Dragon Impérial', '/images/cards/arkus.jpg'),
  close_ranks: d('Serrez les Rangs', '/images/cards/close_ranks.jpg'),
  command: d('Commandement', '/images/cards/command.jpg'),
  darian: d('Darian, Mage de Guerre', '/images/cards/darian.jpg'),
  domination: d('Domination', '/images/cards/domination.jpg'),
  cristov: d('Cristov, le Juste', '/images/cards/cristov.jpg'),
  kraka: d('Kraka, Grand Prêtre', '/images/cards/kraka.jpg'),
  man_at_arms: d("Homme d'Armes", '/images/cards/man_at_arms.jpg'),
  weyan: d('Maître Weyan', '/images/cards/weyan.jpg'),
  rally_troops: d('Ralliement des Troupes', '/images/cards/rally_troops.jpg'),
  recruit: d('Recrutement', '/images/cards/recruit.jpg'),
  tithe_priest: d('Percepteur de Dîme', '/images/cards/tithe_priest.jpg'),
  taxation: d('Taxation', '/images/cards/taxation.jpg'),
  word_of_power: d('Parole de Puissance', '/images/cards/word_of_power.jpg'),

  // Necros

  cult_priest: d('Prêtre du Culte', '/images/cards/cult_priest.jpg'),
  dark_energy: d('Énergie Sombre', '/images/cards/dark_energy.jpg'),
  dark_reward: d('Sombre Récompense', '/images/cards/dark_reward.jpg'),
  death_cultist: d('Cultiste de la Mort', '/images/cards/death_cultist.jpg'),
  death_touch: d('Contact Mortel', '/images/cards/death_touch.jpg'),
  rayla: d('Rayla, Tisseuse de Fins', '/images/cards/rayla.jpg'),
  influence: d('Influence', '/images/cards/influence.jpg'),
  krythos: d('Krythos, Maître Vampire', '/images/cards/krythos.jpg'),
  life_drain: d('Drain de Vie', '/images/cards/life_drain.jpg'),
  lys: d("Lys, l'Inapparent", '/images/cards/lys.jpg'),
  the_rot: d('La Putréfaction', '/images/cards/the_rot.jpg'),
  tyrannor: d('Tyrannor, le Dévoreur', '/images/cards/tyrannor.jpg'),
  varrick: d('Varrick, le Nécromancien', '/images/cards/varrick.jpg'),

  // Wild

  broelyn: d('Broelyn, Tisseuse de Savoirs', '/images/cards/broelyn.jpg'),
  cron: d('Cron, le Berserker', '/images/cards/cron.jpg'),
  dire_wolf: d('Loup Terrifiant', '/images/cards/dire_wolf.jpg'),
  elven_curse: d('Malédiction Elfique', '/images/cards/elven_curse.jpg'),
  elven_gift: d('Don Elfique', '/images/cards/elven_gift.jpg'),
  grak: d('Grak, Géant de la Tempête', '/images/cards/grak.jpg'),
  natures_bounty: d('Don de la Nature', '/images/cards/natures_bounty.jpg'),
  orc_grunt: d('Grognard Orque', '/images/cards/orc_grunt.jpg'),
  rampage: d('Sauvagerie', '/images/cards/rampage.jpg'),
  torgen: d('Torgen Brise-Pierre', '/images/cards/torgen.jpg'),
  spark: d('Étincelle', '/images/cards/spark.jpg'),
  wolf_form: d('Forme de Loup', '/images/cards/wolf_form.jpg'),
  wolf_shaman: d('Shamane des Loups', '/images/cards/wolf_shaman.jpg'),
  /* eslint-enable @typescript-eslint/camelcase */
}
