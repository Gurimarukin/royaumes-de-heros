// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from '../css/app.css'

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import 'phoenix_html'

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

// LiveView
import { Socket } from 'phoenix'
import LiveSocket from 'phoenix_live_view'

const hooks = {
    cards: {
        mapCards(f) {
            const cards = JSON.parse(
                this.el.getAttribute(this.__view.binding('value-cards'))
            )
            cards.map(([id, card]) => f(id, card))
        },
        onClick(button, id) {
            this.pushEvent('card-click', { button, id })
        },
        mounted() {
            const cardsElt = document.getElementById('cards')

            this.mapCards((id, card) => {
                const img = document.createElement('img')

                img.id = id
                img.className = card.class
                img.src = card.card.image
                img.setAttribute('phx-throttle', '500')

                img.addEventListener('click', e => {
                    if (e.button === 0) {
                        e.stopPropagation()
                        this.onClick('left', id)
                    }
                })
                img.addEventListener('contextmenu', e => {
                    e.preventDefault()
                    this.onClick('right', id)
                })

                cardsElt.appendChild(img)
            })
        },
        updated() {
            this.mapCards((id, card) => {
                const img = document.getElementById(id)
                if (img === null) {
                    console.error(`getElementById(${id}) was null`)
                } else {
                    img.className = card.class
                    img.src = card.card.image
                }
            })
        }
    }
}

const liveSocket = new LiveSocket('/live', Socket, { hooks })
liveSocket.connect()
