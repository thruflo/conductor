defmodule ConductorWeb.ChunkController do
  use ConductorWeb, :controller
  alias Conductor.Audio

  @doc """
  Sync a dynamic shape using `Phoenix.Sync.Controller.sync_render/3`.

  The shape is defined at runtime by an Ecto.Query using the request params.
  """
  def show(conn, %{"track_id" => track_id} = params) do
    query = from(c in Audio.Chunk, where: c.track_id == ^track_id)

    sync_render(conn, params, query)
  end
end
