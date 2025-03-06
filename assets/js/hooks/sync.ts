import { type ViewHook } from 'phoenix_live_view'

import * as Audio from '../audio'

import { minOneTripLatency } from '../config'
import { timeSync } from '../time'

const resolveMap = new Map()

function handleTime({ t1, s1 }) {
  if (!resolveMap.has(t1)) {
    return
  }

  const resolve = resolveMap.get(t1)
  resolve(s1)

  resolveMap.delete(t1)
}

function handleSchedule({ time }) {
  timeSync.resolveScheduledTime(time)
}

function handleVolume({ level }) {
  Audio.setVolume(level)
}

const viewHook: ViewHook = {
  mounted() {
    this.handleEvent('time', handleTime)
    this.handleEvent('schedule', handleSchedule)
    this.handleEvent('volume', handleVolume)

    timeSync.configure(this, minOneTripLatency)
  },
  sendTime(t1) {
    return new Promise(resolve => {
      resolveMap.set(t1, resolve)

      this.pushEvent('time', { t1 })
    })
  }
}

export default viewHook
