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
    autofocus: {
        mounted() {
            this.el.focus()
            this.el.select()
        }
    },

    playerName: {
        getValue(field) {
            return this.el.getAttribute(this.__view.binding('value-' + field))
        },
        mounted() {
            this.name = this.getValue('name')
        },
        updated() {
            const newValue = this.getValue('name')
            if (this.name !== newValue) {
                this.name = newValue

                const route = this.getValue('route')
                const csrfToken = this.getValue('csrf-token')

                fetch(location.origin + route, {
                    method: 'POST',
                    headers: {
                        Accept: 'application/json',
                        'Content-Type': 'application/json',
                        'X-CSRF-Token': csrfToken
                    },
                    body: JSON.stringify({ name: newValue })
                })
            }
        }
    },

    fullscreenBtn: {
        mounted() {
            this.el.addEventListener('click', _ => {
                document.body.requestFullscreen()
            })
        }
    },

    card: {
        getValue(field) {
            return this.el.getAttribute(this.__view.binding('value-' + field))
        },
        mounted() {
            this.el.addEventListener('click', e => {
                if (e.button === 0) {
                    e.stopPropagation()
                    this.pushEvent('card_click', { id: this.getValue('id') })
                }
            })
            // this.el.addEventListener('contextmenu', e => {
            //     e.preventDefault()
            // })
        }
    }
}

const liveSocket = new LiveSocket('/live', Socket, { hooks })
liveSocket.connect()
