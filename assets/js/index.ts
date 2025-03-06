import 'phoenix_html'
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'

import { renderApp } from './app'
import { assetPath } from './assets'
import { play, sync } from './hooks'
import { prepareSounds } from './sound'

const csrfToken =
  document
    .querySelector("meta[name='csrf-token']")
    .getAttribute('content')

const liveSocket = new LiveSocket('/live', Socket, {
  hooks: {
    play,
    sync
  },
  longPollFallbackMs: undefined,
  params: {_csrf_token: csrfToken}
})
liveSocket.connect()
liveSocket.disableDebug()

// Audio needs to be started in response to user interaction.
const startButton = document.getElementById('start-button')
startButton.addEventListener('click', prepareSounds)

const syncAppElement = document.getElementById('sync-app')
renderApp(syncAppElement)