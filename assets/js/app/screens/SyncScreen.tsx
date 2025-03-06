import React, { useEffect, useMemo, useState } from 'react'

import { useNavigate, useParams } from 'react-router'
import { useSnapshot } from 'valtio'

import { Shape, ShapeStream } from '@electric-sql/client'

import * as Audio from '../../audio'

import { assetPath } from '../../assets'
import { arrayFromChunks } from '../../chunks'
import { store } from '../../store'
import { timeSync } from '../../time'

import {
  InstrumentListing,
  WaveformAnimation,
  WaveformVisualization
} from '../components'

export default function SyncScreen() {
  const navigate = useNavigate()
  const { instrument } = useParams()

  const snap = useSnapshot(store)

  const [ audioBuffer, setAudioBuffer ] = useState()
  const [ chunks, setChunks ] = useState()
  const [ clockSkew, setClockSkew ] = useState()
  const [ countdown, setCountdown ] = useState(0)
  const [ scheduledTime, setScheduledTime ] = useState()

  // Playback visualization.
  const [ backgroundColor, setBackgroundColor ] = useState('#1B1B1F')
  const [ dataArray, setDataArray ] = useState()

  const isLoaded = audioBuffer !== undefined
  const isReady = isLoaded && clockSkew !== undefined
  const shouldPlay = isReady && scheduledTime !== undefined

  const hasPlayedOnce = snap.get('hasPlayedOnce') ?? false
  const tracks = snap.get('tracks')
  const track = tracks?.find(track => track.name === instrument)

  function reschedule() {
    setScheduledTime(Date.now() + 6)
  }

  const buttonLabel = useMemo(() => {
    if (isReady) {
      return hasPlayedOnce ? 'Play' : 'Ready!'
    }

    if (isLoaded) {
      return 'Syncing clocks'
    }

    if (track?.num_chunks > 0) {
      return 'Syncing data'
    }

    return 'No data'
  }, [isReady, isLoaded, hasPlayedOnce, track?.num_chunks])

  // Monitor the clock
  useEffect(() => {
    let isMounted = true

    async function init() {
      const skew = await timeSync.clockSkew

      if (!isMounted) {
        return
      }

      setClockSkew(skew)

      const time = await timeSync.scheduledTime

      if (!isMounted) {
        return
      }

      setScheduledTime(time)
    }

    init()

    return () => {
      isMounted = false
    }
  }, [])

  // Sync in the chunks of audio data for the selected track.
  useEffect(() => {
    if (track === undefined) {
      return
    }

    const controller = new AbortController()
    const signal = controller.signal

    const stream = new ShapeStream({
      url: new URL(`/shape/chunks`, window.location.href).href,
      params: {
        track_id: track.id,
      },
      signal
    })
    const shape = new Shape(stream)
    const unsubscribe = shape.subscribe(data => setChunks(data.rows))

    return () => {
      unsubscribe()

      controller.abort()
    }
  }, [track])

  // When the chunks are synced, preload the audio data.
  useEffect(() => {
    let shouldContinue = true

    if (chunks === undefined || track === undefined || track.num_chunks === 0) {
      setAudioBuffer(undefined)

      return
    }

    const filteredChunks = chunks.filter(chunk => chunk.track_id === track.id)
    if (filteredChunks.length !== track.num_chunks) {
      setAudioBuffer(undefined)

      return
    }

    const sortedChunks = filteredChunks.sort((a, b) => a.index - b.index)
    const array = arrayFromChunks(sortedChunks)

    async function preload() {
      const audioBuffer = await Audio.preloadArrayBuffer(track.name, array.buffer)

      if (!shouldContinue) {
        return
      }

      setAudioBuffer(audioBuffer)
    }

    const preloadPromise = preload()

    return () => {
      shouldContinue = false

      preloadPromise.then(() => Audio.unload(track.name))
    }
  }, [track, chunks])

  // When ready and scheduled, play the track and display the
  // countdown and waveform animation.
  useEffect(() => {
    if (!shouldPlay) {
      return
    }

    // Play the track.
    const { analyser, source } = Audio.playAt(track.name, scheduledTime - clockSkew)
    source.onended = () => {
      cancelAnimationFrame(animationId)

      window.setTimeout(() => {
        store.set('hasPlayedOnce', true)

        setScheduledTime(undefined)
      }, 2000)
    }

    // Display the countdown.
    let countdownId

    function runCountdown() {
      countdownId = requestAnimationFrame(runCountdown)

      const t1 = Date.now() // ms
      const startInMs = scheduledTime - clockSkew - t1
      const countdownSecs = Math.floor(startInMs / 1000)

      setCountdown(countdownSecs)

      if (countdownSecs < 1) {
        cancelAnimationFrame(countdownId)
      }
    }

    runCountdown()

    // Display the waveform animation.
    let animationId

    function getAverageAmplitude(dataArray) {
      let sum = 0

      for (let i = 0; i < dataArray.length; i++) {
          sum += Math.abs(dataArray[i] - 128)
      }

      return sum / dataArray.length
    }

    function draw() {
      animationId = requestAnimationFrame(draw)

      const bufferLength = analyser.frequencyBinCount
      const dataArray = new Uint8Array(bufferLength)

      analyser.getByteTimeDomainData(dataArray)
      const averageAmplitude = getAverageAmplitude(dataArray)

      // Normalize to 0-1 range.
      const intensity = averageAmplitude / 128
      setBackgroundColor(`rgba(0, 255, 255, ${intensity.toFixed(2)})`)

      // Render the waveform.
      setDataArray(dataArray)
    }

    draw()

    return () => {
      cancelAnimationFrame(countdownId)
      cancelAnimationFrame(animationId)

      setBackgroundColor('#1B1B1F')
      setDataArray(undefined)

      Audio.stop(analyser, source)
    }
  }, [shouldPlay])

  return (
    <div id="sync-screen" className="screen">
      <div className="screen" style={{backgroundColor: backgroundColor}}>
        <div className="w-full text-center my-2">
          <div className="smaller-logo w-full">
            <img className="w-full max-w-40 mx-auto"
                src={assetPath('/images/conductor.png')}
            />
          </div>
        </div>
        {shouldPlay ? (
          countdown > 0 ? (
            <div className="text-9xl h-64 mb-16">
              { countdown }
            </div>
          ) : (
            <div className="w-full h-64 mb-16">
              <WaveformAnimation dataArray={dataArray} />
            </div>
          )
        ) : (
          <>
            <div className="w-9/12 max-w-96 mx-auto mt-2 mb-3 text-left">
              <div className="my-3 py-3 ps-8 pe-6 border rounded-md cursor-pointer flex flex-row justify-between align-center">
                <InstrumentListing name={instrument} />
                {!shouldPlay && (
                  <a className="shrink ps-5 border-s my-1 hover:text-brand"
                      onClick={() => { navigate("/app/sync") }}>
                    ←</a>
                )}
              </div>
            </div>
            <div className="w-11/12 waveform-pad px-4 h-64 mt-6 mb-6 mx-auto">
              <WaveformVisualization audioBuffer={audioBuffer} />
            </div>
            <a id="ready-button"
                className={`progress mb-12 text-center ${hasPlayedOnce ? 'button' : 'w-full'}`}
                disabled={!hasPlayedOnce}
                onClick={() => reschedule()}>
              { buttonLabel }</a>
          </>
        )}
      </div>
    </div>
  )
}