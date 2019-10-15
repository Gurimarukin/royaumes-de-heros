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
    card: {
        mounted() {
            const onClick = button => {
                const id = this.el.id
                this.pushEvent('card-click', { button, id })
            }

            this.el.addEventListener('click', e => {
                if (e.button === 0) {
                    e.stopPropagation()
                    onClick('left')
                }
            })
            this.el.addEventListener('contextmenu', e => {
                e.preventDefault()
                onClick('right')
            })
        }
    }
}

const liveSocket = new LiveSocket('/live', Socket, { hooks })
liveSocket.connect()
