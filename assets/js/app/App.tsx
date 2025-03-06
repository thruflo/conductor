import React, { useEffect, useState } from 'react'

import { BrowserRouter, Routes, Route } from 'react-router'
import { useSnapshot } from 'valtio'

import { useShape } from '@electric-sql/react'

import { store } from '../store'

import { ChooseScreen, SyncScreen } from './screens'

export default function SyncApp() {
  const snap = useSnapshot(store)
  const tracks = snap.get('tracks')

  const { isLoading, data } = useShape({
    url: new URL(`/shape/tracks`, window.location.href).href
  })

  useEffect(() => {
    if (data === undefined) {
      return
    }

    const sortedTracks = [...data].sort((a, b) => {
      return a.name > b.name ? 1 : -1
    })

    store.set('tracks', sortedTracks)
  }, [data])

  if (tracks === undefined) {
    return null
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route path="app" element={<div>erm</div>} />
        <Route path="app/sync" element={<ChooseScreen />} />
        <Route path="app/sync/:instrument" element={<SyncScreen />} />
      </Routes>
    </BrowserRouter>
  )
}
