defmodule ConductorWeb.Router do
  @moduledoc """
  Expose the LiveView app at `/app`.

  Sync tracks and chunks to the front-end using Phoenix.Sync.
  """

  use ConductorWeb, :router
  alias Conductor.Audio

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, html: {ConductorWeb.Layouts, :root}
    plug :put_layout, html: false
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/shape" do
    # Expose a controller that uses `Phoenix.Sync.Controller.sync_render/3`
    # to construct and sync a dynamic shape
    get "/chunks", ConductorWeb.ChunkController, :show

    # Expose a static shape, defined at compile time.
    sync "/tracks", Audio.Track
  end

  scope "/app", ConductorWeb do
    pipe_through :browser

    live "/*path", IndexLive
  end
end
