const audioContext = new AudioContext()
const gainNode = audioContext.createGain()
gainNode.gain.value = 1.0
gainNode.connect(audioContext.destination)

const buffers = new Map()
const sources = new Array()
const analysers = new Array()

export function setVolume(level) {
  gainNode.gain.exponentialRampToValueAtTime(level, audioContext.currentTime + 1.5)
}

export async function start() {
  await audioContext.resume()
}

export async function preloadUrl(name, url) {
  try {
    const response = await fetch(url)
    const arrayBuffer = await response.arrayBuffer()

    return await preloadArrayBuffer(name, arrayBuffer)
  } catch (error) {
    console.error('Error preloading URL', name, error)

    throw error
  }
}

export async function preloadArrayBuffer(name, arrayBuffer) {
  try {
    const audioBuffer = await audioContext.decodeAudioData(arrayBuffer)

    buffers.set(name, audioBuffer)

    return audioBuffer
  } catch (error) {
    console.error('Error preloading ArrayBuffer', name, error)

    throw error
  }
}

export function play(name) {
  if (audioContext.state !== 'running') {
    console.error('Can\'t play because audioContext isn\'t running')
  }

  const source = audioContext.createBufferSource()
  source.buffer = buffers.get(name)
  source.connect(gainNode)
  source.start(0)

  sources.push(source)

  return source
}

export function playAt(name, scheduledTimestamp) {
  if (audioContext.state !== 'running') {
    console.error('Can\'t play because audioContext isn\'t running')
  }

  const analyser = audioContext.createAnalyser()
  analyser.fftSize = 2048
  analyser.connect(gainNode)
  analysers.push(analyser)

  const source = audioContext.createBufferSource()
  source.buffer = buffers.get(name)
  source.connect(analyser)
  sources.push(source)

  const t1 = Date.now() // ms
  const startInMs = scheduledTimestamp - t1
  const startInSecs = startInMs / 1000

  source.start(audioContext.currentTime + startInSecs)

  return {
    analyser,
    source
  }
}

export function stop(analyser, source) {
  source.stop()
  source.disconnect(analyser)
  sources.pop(source)

  analyser.disconnect(gainNode)
  analysers.pop(analyser)
}

export function stopAll() {
  analysers.forEach(analyser => {
    analyser.disconnect(gainNode)
  })

  sources.forEach(source => {
    source.stop()
    source.disconnect()
  })

  // Clears the arrays
  analysers.length = 0
  sources.length = 0
}

export function unload(id) {
  buffers.delete(id)
}

export function unloadAll(id) {
  buffers.clear(id)
}

export function status() {
  return audioContext.state
}
