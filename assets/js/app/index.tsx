import React, { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'

import App from './App'

export function renderApp(el) {
  createRoot(el).render(
    <StrictMode>
      <App />
    </StrictMode>
  )
}
