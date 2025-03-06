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

    timeout = window.setTimeout(() => {
      classList.remove(className)
    }, 1800)
  }
}

export default viewHook
