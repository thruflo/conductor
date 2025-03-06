defmodule Mix.Tasks.Populate do
  use Mix.Task
  alias Conductor.Audio
  alias Conductor.Bootstrap

  def run([song, name]) do
    [:postgrex, :ecto]
    |> Enum.each(&Application.ensure_all_started/1)

    Conductor.Repo.start_link()

    Audio.get_track_for(song, name)
    |> Bootstrap.populate_chunks()
  end
end
