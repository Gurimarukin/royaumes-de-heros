import 'phoenix_html'

import '../css/app.css'

import React from 'react'
import ReactDOM from 'react-dom'

import { App } from './components/App'

;

(window as any).startApp = (user: unknown, cardData: unknown, csrfToken: unknown): void => {
  ReactDOM.render(
    <App user={user} card_data={cardData} csrf_token={csrfToken} />,
    document.getElementById('root'),
  )
}
