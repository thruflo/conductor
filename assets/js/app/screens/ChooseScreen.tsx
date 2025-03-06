import React, { useEffect, useState } from 'react'

import { useNavigate } from 'react-router'
import { useSnapshot } from 'valtio'

import * as Audio from '../../audio'
import { assetPath } from '../../assets'
import { store } from '../../store'
import { timeSync } from '../../time'

import { InstrumentListing } from '../components'

export default function ChooseScreen() {
  const navigate = useNavigate()

  const snap = useSnapshot(store)
  const tracks = snap.get('tracks')

  const [ instrument, setInstrument ] = useState()

  useEffect(() => {
    timeSync.start()

    Audio.stopAll()
  }, [])

  return (
    <div id="choose-screen" className="screen">
      <div className="w-full text-center my-2">
        <div className="smaller-logo w-full">
          <img className="w-full max-w-40 mx-auto"
              src={assetPath('/images/conductor.png')}
          />
        </div>
        <h1 className="text-2xl">
          Choose your instrument
        </h1>
      </div>
      <ul className="choose-instruments w-9/12 max-w-96 mt-2 mb-4">
        {tracks.map(track => {
          const isChosen = track.name === instrument

          const coreClassNames = `my-3 py-3 px-8 border rounded-md cursor-pointer`
          const classNames = `${coreClassNames}${isChosen ? ' border-brand text-brand' : ''}`

          return (
            <li key={track.name} className={classNames}
                onClick={() => { setInstrument(track.name) }}>
              <InstrumentListing name={track.name} />
            </li>
          )
        })}
      </ul>
      <a id="select-button" className="button w-9/12 max-w-80 mb-12 text-center"
          disabled={instrument === undefined}
          onClick={() => { navigate(`/app/sync/${instrument}`) }}>
        Select</a>
    </div>
  )
}