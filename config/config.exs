# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :conductor,
  ecto_repos: [Conductor.Repo]

config :conductor, Conductor.Repo, types: Conductor.PostgrexTypes

config :phoenix_sync,
  mode: :embedded,
  repo: Conductor.Repo

# Configures the endpoint
config :conductor, ConductorWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ConductorWeb.ErrorHTML, json: ConductorWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Conductor.PubSub,
  live_view: [signing_salt: "k6ymkac2"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  app: [
    args: [
      "js/index.ts",
      "--bundle",
      "--external:/fonts/*",
      "--external:/images/*",
      "--external:/pglite/*",
      "--loader:.sql=file",
      "--loader:.svg=file",
      "--outdir=../priv/static/assets",
      "--target=es2020"
    ],
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  conductor: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
