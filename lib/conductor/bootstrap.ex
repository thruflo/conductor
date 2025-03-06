defmodule Conductor.Bootstrap do
  alias Conductor.Audio
  alias Conductor.Audio.{Song, Track}
  alias Conductor.Vector

  @doc """
  Bootstrap the database entries for a song.

  ## Examples

      iex> bootstrap_song("arena")
      {:ok, %Song{}, [%Track{}, ...]}

  """
  def bootstrap_song(name) when is_binary(name) do
    {:ok, song} = Audio.create_song(%{name: name})

    {:ok, song, bootstrap_tracks(song)}
  end

  defp bootstrap_tracks(%Song{id: song_id, name: song_name}) do
    folder_path = "priv/static/audio/songs/#{song_name}"

    Application.app_dir(:conductor, folder_path)
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".mp3"))
    |> Enum.map(fn filename ->
      name = Path.rootname(filename, ".mp3")

      attrs = %{
        name: name,
        song_id: song_id
      }

      {:ok, track} = Audio.create_track(attrs)

      track
    end)
  end

  @doc """
  Populate the chunks for a track.

  ## Examples

      iex> populate_chunks(%Track{})
      {:ok, results}

  """
  def populate_chunks(%Track{name: name, song: %Song{name: song}} = track) do
    "priv/static/audio/songs/#{song}/#{name}.mp3"
    |> Vector.mp3_to_vectors()
    |> Vector.save_vectors_to_track(track)
  end
end
