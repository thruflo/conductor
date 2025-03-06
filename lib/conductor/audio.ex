defmodule Conductor.Audio do
  @moduledoc """
  The Push context.
  """

  import Ecto.Query, warn: false
  alias Conductor.Repo

  alias Conductor.Audio.Sound

  @doc """
  Returns the list of sounds.

  ## Examples

      iex> list_sounds()
      [%Sound{}, ...]

  """
  def list_sounds do
    Repo.all(Sound)
  end

  @doc """
  Gets a single sound.

  Raises `Ecto.NoResultsError` if the Sound does not exist.

  ## Examples

      iex> get_sound!(123)
      %Sound{}

      iex> get_sound!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sound!(id), do: Repo.get!(Sound, id)

  @doc """
  Creates a sound.

  ## Examples

      iex> create_sound(%{field: value})
      {:ok, %Sound{}}

      iex> create_sound(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sound(attrs \\ %{}) do
    %Sound{}
    |> Sound.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sound.

  ## Examples

      iex> update_sound(sound, %{field: new_value})
      {:ok, %Sound{}}

      iex> update_sound(sound, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sound(%Sound{} = sound, attrs) do
    sound
    |> Sound.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sound.

  ## Examples

      iex> delete_sound(sound)
      {:ok, %Sound{}}

      iex> delete_sound(sound)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sound(%Sound{} = sound) do
    Repo.delete(sound)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sound changes.

  ## Examples

      iex> change_sound(sound)
      %Ecto.Changeset{data: %Sound{}}

  """
  def change_sound(%Sound{} = sound, attrs \\ %{}) do
    Sound.changeset(sound, attrs)
  end

  alias Conductor.Audio.Song

  @doc """
  Returns the list of songs.

  ## Examples

      iex> list_songs()
      [%Song{}, ...]

  """
  def list_songs do
    Repo.all(Song)
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the Song does not exist.

  ## Examples

      iex> get_song!(123)
      %Song{}

      iex> get_song!(456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(id), do: Repo.get!(Song, id)

  @doc """
  Creates a song.

  ## Examples

      iex> create_song(%{field: value})
      {:ok, %Song{}}

      iex> create_song(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_song(attrs \\ %{}) do
    %Song{}
    |> Song.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a song.

  ## Examples

      iex> update_song(song, %{field: new_value})
      {:ok, %Song{}}

      iex> update_song(song, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_song(%Song{} = song, attrs) do
    song
    |> Song.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a song.

  ## Examples

      iex> delete_song(song)
      {:ok, %Song{}}

      iex> delete_song(song)
      {:error, %Ecto.Changeset{}}

  """
  def delete_song(%Song{} = song) do
    Repo.delete(song)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking song changes.

  ## Examples

      iex> change_song(song)
      %Ecto.Changeset{data: %Song{}}

  """
  def change_song(%Song{} = song, attrs \\ %{}) do
    Song.changeset(song, attrs)
  end

  alias Conductor.Audio.Track

  @doc """
  Returns the list of tracks.

  ## Examples

      iex> list_tracks()
      [%Track{}, ...]

  """
  def list_tracks do
    Repo.all(Track)
  end

  @doc """
  Gets a single track.

  Raises `Ecto.NoResultsError` if the Track does not exist.

  ## Examples

      iex> get_track!(123)
      %Track{}

      iex> get_track!(456)
      ** (Ecto.NoResultsError)

  """
  def get_track!(id), do: Repo.get!(Track, id)

  @doc """
  Get the tracks for a named song.

  Raises `Ecto.NoResultsError` if the Track does not exist.

  ## Examples

      iex> get_track_for(%Song{}, "synth")
      %Track{}

  """
  def get_track_for(song_name, track_name) when is_binary(song_name) and is_binary(track_name) do
    Track
    |> join(:inner, [t], s in Song, on: t.song_id == s.id)
    |> where([t, s], s.name == ^song_name)
    |> where([t, s], t.name == ^track_name)
    |> preload([t, s], :song)
    |> order_by([t, s], t.name)
    |> Repo.one()
  end

  @doc """
  Creates a track.

  ## Examples

      iex> create_track(%{field: value})
      {:ok, %Track{}}

      iex> create_track(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_track(attrs \\ %{}) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a track.

  ## Examples

      iex> update_track(track, %{field: new_value})
      {:ok, %Track{}}

      iex> update_track(track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_track(%Track{} = track, attrs) do
    track
    |> Track.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a track.

  ## Examples

      iex> delete_track(track)
      {:ok, %Track{}}

      iex> delete_track(track)
      {:error, %Ecto.Changeset{}}

  """
  def delete_track(%Track{} = track) do
    Repo.delete(track)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking track changes.

  ## Examples

      iex> change_track(track)
      %Ecto.Changeset{data: %Track{}}

  """
  def change_track(%Track{} = track, attrs \\ %{}) do
    Track.changeset(track, attrs)
  end

  alias Conductor.Audio.Chunk

  @doc """
  Returns the list of chunks.

  ## Examples

      iex> list_chunks()
      [%Chunk{}, ...]

  """
  def list_chunks do
    Repo.all(Chunk)
  end

  @doc """
  Gets a single chunk.

  Raises `Ecto.NoResultsError` if the Chunk does not exist.

  ## Examples

      iex> get_chunk!(123)
      %Chunk{}

      iex> get_chunk!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chunk!(id), do: Repo.get!(Chunk, id)

  @doc """
  Initialises a chunk.

  ## Examples

      iex> init_chunk(%{field: value})
      %Ecto.Changeset{}

  """
  def init_chunk(attrs \\ %{}) do
    %Chunk{}
    |> Chunk.changeset(attrs)
  end

  @doc """
  Creates a chunk.

  ## Examples

      iex> create_chunk(%{field: value})
      {:ok, %Chunk{}}

      iex> create_chunk(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chunk(attrs \\ %{}) do
    %Chunk{}
    |> Chunk.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chunk.

  ## Examples

      iex> update_chunk(chunk, %{field: new_value})
      {:ok, %Chunk{}}

      iex> update_chunk(chunk, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chunk(%Chunk{} = chunk, attrs) do
    chunk
    |> Chunk.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chunk.

  ## Examples

      iex> delete_chunk(chunk)
      {:ok, %Chunk{}}

      iex> delete_chunk(chunk)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chunk(%Chunk{} = chunk) do
    Repo.delete(chunk)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chunk changes.

  ## Examples

      iex> change_chunk(chunk)
      %Ecto.Changeset{data: %Chunk{}}

  """
  def change_chunk(%Chunk{} = chunk, attrs \\ %{}) do
    Chunk.changeset(chunk, attrs)
  end
end
