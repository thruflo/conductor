import { subscribe } from 'valtio'
import { proxyMap } from 'valtio/utils'

const KEY = 'conductor:store'

function stringify(data) {
  return JSON.stringify(data, (_key, value) => (
    typeof value === "bigint"
    ? JSON.rawJSON(value.toString())
    : value
  ))
}

export const store = proxyMap(
  JSON.parse(localStorage.getItem(KEY) || '[]')
)

subscribe(store, () => {
  localStorage.setItem(KEY, stringify([...store.entries()]))
})
