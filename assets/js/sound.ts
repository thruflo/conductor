import * as Audio from './audio'
import { assetPath } from './assets'

const sounds = ['clap', 'tada']

export async function prepareSounds() {
  await Audio.start()

  await Promise.all(sounds.map(prepareSound))
}

async function prepareSound(name) {
  const url = assetPath(`/audio/sounds/${name}.mp3`)

  await Audio.preloadUrl(name, url)
}