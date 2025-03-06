defmodule Conductor.AudioFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Conductor.Audio` context.
  """
  alias Conductor.Audio

  alias Conductor.Audio.{
    Song,
    Track
  }

  @doc """
  Generate a sound.
  """
  def sound_fixture(attrs \\ %{}) do
    {:ok, sound} =
      attrs
      |> Enum.into(%{
        name: "some name",
        speed: "120.5"
      })
      |> Audio.create_sound()

    sound
  end

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{}) do
    {:ok, song} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Audio.create_song()

    song
  end

  @doc """
  Generate a track.
  """
  def track_fixture(%Song{id: song_id}, attrs \\ %{}) do
    {:ok, track} =
      attrs
      |> Enum.into(%{
        song_id: song_id,
        name: "some name",
        num_chunks: 0
      })
      |> Audio.create_track()

    track
  end

  @doc """
  Generate a chunk.
  """
  def chunk_fixture(%Track{id: track_id}, attrs \\ %{}) do
    {:ok, chunk} =
      attrs
      |> Enum.into(%{
        track_id: track_id,
        index: 0,
        value: List.duplicate(1.0, 1000)
      })
      |> Audio.create_chunk()

    chunk
  end
end
