import React from 'react'
import InstrumentIcon from './InstrumentIcon'

export default function InstrumentListing({ name }) {
  return (
    <div className="instrument flex flex-row items-center gap-4">
      <InstrumentIcon className="flex-initial w-8" name={ name } />
      <div className="flex-grow capitalize text-lg ps-4">
        { name }
      </div>
    </div>
  )
}
