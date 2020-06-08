import { lookup } from 'fp-ts/lib/ReadonlyRecord'

import { Dict, Maybe } from './fp'

export type Faction = 'guild' | 'imperial' | 'necros' | 'wild'

export type CardData = {
  readonly name: string
  readonly image: string
  readonly faction: Maybe<Faction>
} & Abilities

interface Abilities {
  readonly expend: boolean
  readonly ally: boolean
  readonly sacrifice: boolean
}

function d(
  name: string,
  image: string,
  faction: Maybe<Faction> = Maybe.none,
  { expend = false, ally = false, sacrifice = false }: Partial<Abilities> = {}
): CardData {
  return { name, image, faction, expend, ally, sacrifice }
}

export namespace CardData {
  export const hidden = 'https://www.herorealms.com/wp-content/uploads/2017/09/hero_realms_back.jpg'

  export function get(key: string): Maybe<CardData> {
    return lookup(key, cards)
  }

  export const cards: Dict<CardData> = {
    /* eslint-disable @typescript-eslint/camelcase */
    shortsword: d(
      'Épée courte',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-125-shortsword.jpg'
    ),
    dagger: d(
      'Dague',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-129-dagger.jpg'
    ),
    ruby: d('Rubis', 'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-133-ruby.jpg'),
    gold: d('Or', 'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-097-gold.jpg'),

    gem: d(
      'Gemme de feu',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-081-fire-gem.jpg',
      Maybe.none,
      { sacrifice: true }
    ),

    // Guild

    borg: d(
      'Borg, Mercenaire Ogre',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-021-borg-ogre-mercenary.jpg',
      Maybe.some('guild'),
      { expend: true }
    ),
    bribe: d(
      'Pot-de-Vin',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-022-bribe.jpg',
      Maybe.some('guild'),
      { ally: true }
    ),
    death_threat: d(
      'Menace de Mort',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-025-death-threat.jpg',
      Maybe.some('guild'),
      { ally: true }
    ),
    deception: d(
      'Fourberie',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-026-deception.jpg',
      Maybe.some('guild'),
      { ally: true }
    ),
    fire_bomb: d(
      'Bombe Incendiaire',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-027-fire-bomb.jpg',
      Maybe.some('guild'),
      { sacrifice: true }
    ),
    hit_job: d(
      'Mise à prix',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-028-hit-job.jpg',
      Maybe.some('guild'),
      { ally: true }
    ),
    intimidation: d(
      'Intimidation',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-029-intimidation.jpg',
      Maybe.some('guild'),
      { ally: true }
    ),
    myros: d(
      'Myros, Mage de la Guilde',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-031-myros-guild-mage.jpg',
      Maybe.some('guild'),
      { expend: true, ally: true }
    ),
    parov: d(
      "Parov, l'Exécuteur",
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-032-parov-the-enforcer.jpg',
      Maybe.some('guild'),
      { expend: true, ally: true }
    ),
    profit: d(
      'Bénéfice',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-033-profit.jpg',
      Maybe.some('guild'),
      { ally: true }
    ),
    rake: d(
      'Rake, Maître Assassin',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-036-rake-master-assassin.jpg',
      Maybe.some('guild'),
      { expend: true }
    ),
    rasmus: d(
      'Rasmus, le Contrebandier',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-037-rasmus-the-smuggler.jpg',
      Maybe.some('guild'),
      { expend: true, ally: true }
    ),
    smash_and_grab: d(
      'Casser et Piller',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-038-smash-and-grab.jpg',
      Maybe.some('guild')
    ),
    street_thug: d(
      'Bandit des Rues',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-039-street-thug.jpg',
      Maybe.some('guild'),
      { expend: true }
    ),

    // Imperial

    arkus: d(
      'Arkus, Dragon Impérial',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-001-arkus-imperial-dragon.jpg',
      Maybe.some('imperial'),
      { expend: true, ally: true }
    ),
    close_ranks: d(
      'Serrez les Rangs',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-002-close-ranks.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    command: d(
      'Commandement',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-003-command.jpg',
      Maybe.some('imperial')
    ),
    darian: d(
      'Darian, Mage de Guerre',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-004-darian-war-mage.jpg',
      Maybe.some('imperial'),
      { expend: true }
    ),
    domination: d(
      'Domination',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-005-domination.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    cristov: d(
      'Cristov, le Juste',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-006-cristov-the-just.jpg',
      Maybe.some('imperial'),
      { expend: true, ally: true }
    ),
    kraka: d(
      'Kraka, Grand Prêtre',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-007-kraka-high-priest.jpg',
      Maybe.some('imperial'),
      { expend: true, ally: true }
    ),
    man_at_arms: d(
      "Homme d'Armes",
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-008-man-at-arms.jpg',
      Maybe.some('imperial'),
      { expend: true }
    ),
    weyan: d(
      'Maître Weyan',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-010-master-weyan.jpg',
      Maybe.some('imperial'),
      { expend: true }
    ),
    rally_troops: d(
      'Ralliement des Troupes',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-011-rally-the-troops.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    recruit: d(
      'Recrutement',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-012-recruit.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    tithe_priest: d(
      'Percepteur de Dîme',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-015-tithe-priest.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    taxation: d(
      'Taxation',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-017-taxation.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    word_of_power: d(
      'Parole de Puissance',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-020-word-of-power.jpg',
      Maybe.some('imperial'),
      { ally: true, sacrifice: true }
    ),

    // Necros

    cult_priest: d(
      'Prêtre du Culte',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-041-cult-priest.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    dark_energy: d(
      'Énergie Sombre',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-043-dark-energy.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    dark_reward: d(
      'Sombre Récompense',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-044-dark-reward.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    death_cultist: d(
      'Cultiste de la Mort',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-045-death-cultist.jpg',
      Maybe.some('necros'),
      { expend: true }
    ),
    death_touch: d(
      'Contact Mortel',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-047-death-touch.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    rayla: d(
      'Rayla, Tisseuse de Fins',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-050-rayla-endweaver.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    influence: d(
      'Influence',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-051-influence.jpg',
      Maybe.some('necros'),
      { sacrifice: true }
    ),
    krythos: d(
      'Krythos, Maître Vampire',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-054-krythos-master-vampire.jpg',
      Maybe.some('necros'),
      { expend: true }
    ),
    life_drain: d(
      'Drain de Vie',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-055-life-drain.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    lys: d(
      "Lys, l'Inapparent",
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-056-lys-the-unseen.jpg',
      Maybe.some('necros'),
      { expend: true }
    ),
    the_rot: d(
      'La Putréfaction',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-057-the-rot.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    tyrannor: d(
      'Tyrannor, le Dévoreur',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-059-tyrannor-the-devourer.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    varrick: d(
      'Varrick, le Nécromancien',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-060-varrick-the-necromancer.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),

    // Wild

    broelyn: d(
      'Broelyn, Tisseuse de Savoirs',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-061-broelyn-loreweaver.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    cron: d(
      'Cron, le Berserker',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-062-cron-the-berserker.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    dire_wolf: d(
      'Loup Terrifiant',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-063-dire-wolf.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    elven_curse: d(
      'Malédiction Elfique',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-064-elven-curse.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    elven_gift: d(
      'Don Elfique',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-066-elven-gift.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    grak: d(
      'Grak, Géant de la Tempête',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-069-grak-storm-giant.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    natures_bounty: d(
      'Don de la Nature',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-070-natures-bounty.jpg',
      Maybe.some('necros'),
      { ally: true, sacrifice: true }
    ),
    orc_grunt: d(
      'Grognard Orque',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-071-orc-grunt.jpg',
      Maybe.some('necros'),
      { expend: true, ally: true }
    ),
    rampage: d(
      'Sauvagerie',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-073-rampage.jpg',
      Maybe.some('necros')
    ),
    torgen: d(
      'Torgen Brise-Pierre',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-074-torgen-rocksplitter.jpg',
      Maybe.some('necros'),
      { expend: true }
    ),
    spark: d(
      'Étincelle',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-075-spark.jpg',
      Maybe.some('necros'),
      { ally: true }
    ),
    wolf_form: d(
      'Forme de Loup',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-078-wolf-form.jpg',
      Maybe.some('necros'),
      { sacrifice: true }
    ),
    wolf_shaman: d(
      'Shamane des Loups',
      'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-079-wolf-shaman.jpg',
      Maybe.some('necros'),
      { expend: true }
    )
    /* eslint-enable @typescript-eslint/camelcase */
  }
}
