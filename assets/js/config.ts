type Manifest = {
  [key: string]: string
}

export const assetManifest = window.ASSET_MANIFEST as Manifest
export const minOneTripLatency = window.MINIMUM_ONE_TRIP_LATENCY as number
