import { Dict } from './fp'

interface CardData {
  readonly name: string
  readonly image: string
  readonly expend: boolean
  readonly ally: boolean
  readonly sacrifice: boolean
}

function d(
  name: string,
  image: string,
  expend: boolean = false,
  ally: boolean = false,
  sacrifice: boolean = false
): CardData {
  return { name, image, expend, ally, sacrifice }
}

export const CardsData: Dict<CardData> = {
  shortsword: d(
    'Épée courte',
    'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-125-shortsword.jpg'
  ),
  dagger: d('Dague', 'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-129-dagger.jpg'),
  ruby: d('Rubis', 'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-133-ruby.jpg'),
  gold: d('Or', 'https://www.herorealms.com/wp-content/uploads/2017/09/BAS-EN-097-gold.jpg')
}
