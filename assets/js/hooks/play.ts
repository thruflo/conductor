import { type ViewHook } from 'phoenix_live_view'
import * as Audio from '../audio'

let timeout: number

const viewHook: ViewHook = {
  mounted() {
    if (Audio.status() !== 'running') {
      return
    }

    if (window.location.pathname.startsWith('/app/sync')) {
      return
    }

    window.clearTimeout(timeout)

    const name = this.el.getAttribute('data-sound')
    Audio.play(name)

    const className = `playing-${name}`
    const classList = document.getElementById('speaker').classList
    classList.add(className)

    const duration = name === 'icecream' ? 4000 : 1800
    timeout = window.setTimeout(() => {
      classList.remove(className)
    }, duration)
  }
}

export default viewHook
