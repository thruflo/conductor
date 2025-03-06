// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "./js/**/*.tsx",
    "../lib/conductor_web.ex",
    "../lib/conductor_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#00FFFF",
        white: "#F5F5F5",
        black: "#1B1B1F"
      },
      fontFamily: {
        sans: ['OpenSauceOne', 'ui-sans-serif', 'system-ui', 'sans-serif'],
        mono: ['SourceCodePro', 'ui-monospace', 'Menlo', 'Monaco', 'monospace'],
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),
  ]
}
