import { assetManifest } from './config'

export function assetPath(path: string) {
  const isAbsolutePath = path.startsWith('/')

  const key = isAbsolutePath ? path.slice(1) : path
  const value = assetManifest.hasOwnProperty(key) ? assetManifest[key] : key

  return isAbsolutePath ? `/${value}` : value
}
