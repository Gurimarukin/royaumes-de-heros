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
  export const hidden = '/images/cards/hidden.jpg'

  export function get(key: string): Maybe<CardData> {
    return lookup(key, cards)
  }

  export const cards: Dict<CardData> = {
    /* eslint-disable @typescript-eslint/camelcase */
    shortsword: d('Épée courte', '/images/cards/shortsword.jpg'),
    dagger: d('Dague', '/images/cards/dagger.jpg'),
    ruby: d('Rubis', '/images/cards/ruby.jpg'),
    gold: d('Or', '/images/cards/gold.jpg'),

    gem: d('Gemme de feu', '/images/cards/gem.jpg', Maybe.none, { sacrifice: true }),

    // Guild

    borg: d('Borg, Mercenaire Ogre', '/images/cards/borg.jpg', Maybe.some('guild'), {
      expend: true
    }),
    bribe: d('Pot-de-Vin', '/images/cards/bribe.jpg', Maybe.some('guild'), { ally: true }),
    death_threat: d('Menace de Mort', '/images/cards/death_threat.jpg', Maybe.some('guild'), {
      ally: true
    }),
    deception: d('Fourberie', '/images/cards/deception.jpg', Maybe.some('guild'), { ally: true }),
    fire_bomb: d('Bombe Incendiaire', '/images/cards/fire_bomb.jpg', Maybe.some('guild'), {
      sacrifice: true
    }),
    hit_job: d('Mise à prix', '/images/cards/hit_job.jpg', Maybe.some('guild'), { ally: true }),
    intimidation: d('Intimidation', '/images/cards/intimidation.jpg', Maybe.some('guild'), {
      ally: true
    }),
    myros: d('Myros, Mage de la Guilde', '/images/cards/myros.jpg', Maybe.some('guild'), {
      expend: true,
      ally: true
    }),
    parov: d("Parov, l'Exécuteur", '/images/cards/parov.jpg', Maybe.some('guild'), {
      expend: true,
      ally: true
    }),
    profit: d('Bénéfice', '/images/cards/profit.jpg', Maybe.some('guild'), { ally: true }),
    rake: d('Rake, Maître Assassin', '/images/cards/rake.jpg', Maybe.some('guild'), {
      expend: true
    }),
    rasmus: d('Rasmus, le Contrebandier', '/images/cards/rasmus.jpg', Maybe.some('guild'), {
      expend: true,
      ally: true
    }),
    smash_and_grab: d('Casser et Piller', '/images/cards/smash_and_grab.jpg', Maybe.some('guild')),
    street_thug: d('Bandit des Rues', '/images/cards/street_thug.jpg', Maybe.some('guild'), {
      expend: true
    }),

    // Imperial

    arkus: d('Arkus, Dragon Impérial', '/images/cards/arkus.jpg', Maybe.some('imperial'), {
      expend: true,
      ally: true
    }),
    close_ranks: d('Serrez les Rangs', '/images/cards/close_ranks.jpg', Maybe.some('imperial'), {
      ally: true
    }),
    command: d('Commandement', '/images/cards/command.jpg', Maybe.some('imperial')),
    darian: d('Darian, Mage de Guerre', '/images/cards/darian.jpg', Maybe.some('imperial'), {
      expend: true
    }),
    domination: d('Domination', '/images/cards/domination.jpg', Maybe.some('imperial'), {
      ally: true
    }),
    cristov: d('Cristov, le Juste', '/images/cards/cristov.jpg', Maybe.some('imperial'), {
      expend: true,
      ally: true
    }),
    kraka: d('Kraka, Grand Prêtre', '/images/cards/kraka.jpg', Maybe.some('imperial'), {
      expend: true,
      ally: true
    }),
    man_at_arms: d("Homme d'Armes", '/images/cards/man_at_arms.jpg', Maybe.some('imperial'), {
      expend: true
    }),
    weyan: d('Maître Weyan', '/images/cards/weyan.jpg', Maybe.some('imperial'), { expend: true }),
    rally_troops: d(
      'Ralliement des Troupes',
      '/images/cards/rally_troops.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    recruit: d('Recrutement', '/images/cards/recruit.jpg', Maybe.some('imperial'), { ally: true }),
    tithe_priest: d(
      'Percepteur de Dîme',
      '/images/cards/tithe_priest.jpg',
      Maybe.some('imperial'),
      { ally: true }
    ),
    taxation: d('Taxation', '/images/cards/taxation.jpg', Maybe.some('imperial'), { ally: true }),
    word_of_power: d(
      'Parole de Puissance',
      '/images/cards/word_of_power.jpg',
      Maybe.some('imperial'),
      { ally: true, sacrifice: true }
    ),

    // Necros

    cult_priest: d('Prêtre du Culte', '/images/cards/cult_priest.jpg', Maybe.some('necros'), {
      expend: true,
      ally: true
    }),
    dark_energy: d('Énergie Sombre', '/images/cards/dark_energy.jpg', Maybe.some('necros'), {
      ally: true
    }),
    dark_reward: d('Sombre Récompense', '/images/cards/dark_reward.jpg', Maybe.some('necros'), {
      ally: true
    }),
    death_cultist: d(
      'Cultiste de la Mort',
      '/images/cards/death_cultist.jpg',
      Maybe.some('necros'),
      { expend: true }
    ),
    death_touch: d('Contact Mortel', '/images/cards/death_touch.jpg', Maybe.some('necros'), {
      ally: true
    }),
    rayla: d('Rayla, Tisseuse de Fins', '/images/cards/rayla.jpg', Maybe.some('necros'), {
      expend: true,
      ally: true
    }),
    influence: d('Influence', '/images/cards/influence.jpg', Maybe.some('necros'), {
      sacrifice: true
    }),
    krythos: d('Krythos, Maître Vampire', '/images/cards/krythos.jpg', Maybe.some('necros'), {
      expend: true
    }),
    life_drain: d('Drain de Vie', '/images/cards/life_drain.jpg', Maybe.some('necros'), {
      ally: true
    }),
    lys: d("Lys, l'Inapparent", '/images/cards/lys.jpg', Maybe.some('necros'), { expend: true }),
    the_rot: d('La Putréfaction', '/images/cards/the_rot.jpg', Maybe.some('necros'), {
      ally: true
    }),
    tyrannor: d('Tyrannor, le Dévoreur', '/images/cards/tyrannor.jpg', Maybe.some('necros'), {
      expend: true,
      ally: true
    }),
    varrick: d('Varrick, le Nécromancien', '/images/cards/varrick.jpg', Maybe.some('necros'), {
      expend: true,
      ally: true
    }),

    // Wild

    broelyn: d('Broelyn, Tisseuse de Savoirs', '/images/cards/broelyn.jpg', Maybe.some('wild'), {
      expend: true,
      ally: true
    }),
    cron: d('Cron, le Berserker', '/images/cards/cron.jpg', Maybe.some('wild'), {
      expend: true,
      ally: true
    }),
    dire_wolf: d('Loup Terrifiant', '/images/cards/dire_wolf.jpg', Maybe.some('wild'), {
      expend: true,
      ally: true
    }),
    elven_curse: d('Malédiction Elfique', '/images/cards/elven_curse.jpg', Maybe.some('wild'), {
      ally: true
    }),
    elven_gift: d('Don Elfique', '/images/cards/elven_gift.jpg', Maybe.some('wild'), {
      ally: true
    }),
    grak: d('Grak, Géant de la Tempête', '/images/cards/grak.jpg', Maybe.some('wild'), {
      expend: true,
      ally: true
    }),
    natures_bounty: d('Don de la Nature', '/images/cards/natures_bounty.jpg', Maybe.some('wild'), {
      ally: true,
      sacrifice: true
    }),
    orc_grunt: d('Grognard Orque', '/images/cards/orc_grunt.jpg', Maybe.some('wild'), {
      expend: true,
      ally: true
    }),
    rampage: d('Sauvagerie', '/images/cards/rampage.jpg', Maybe.some('wild')),
    torgen: d('Torgen Brise-Pierre', '/images/cards/torgen.jpg', Maybe.some('wild'), {
      expend: true
    }),
    spark: d('Étincelle', '/images/cards/spark.jpg', Maybe.some('wild'), { ally: true }),
    wolf_form: d('Forme de Loup', '/images/cards/wolf_form.jpg', Maybe.some('wild'), {
      sacrifice: true
    }),
    wolf_shaman: d('Shamane des Loups', '/images/cards/wolf_shaman.jpg', Maybe.some('wild'), {
      expend: true
    })
    /* eslint-enable @typescript-eslint/camelcase */
  }
}
