defmodule Conductor.AudioTest do
  use Conductor.DataCase

  alias Conductor.Audio

  alias Conductor.Audio.{
    Chunk,
    Sound,
    Song,
    Track
  }

  describe "sounds" do
    @invalid_attrs %{name: nil, speed: nil}

    test "list_sounds/0 returns all sounds" do
      sound = sound_fixture()
      assert Audio.list_sounds() == [sound]
    end

    test "get_sound!/1 returns the sound with given id" do
      sound = sound_fixture()
      assert Audio.get_sound!(sound.id) == sound
    end

    test "create_sound/1 with valid data creates a sound" do
      valid_attrs = %{name: "some name", speed: "120.5"}

      assert {:ok, %Sound{} = sound} = Audio.create_sound(valid_attrs)
      assert sound.name == "some name"
      assert sound.speed == Decimal.new("120.5")
    end

    test "create_sound/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Audio.create_sound(@invalid_attrs)
    end

    test "update_sound/2 with valid data updates the sound" do
      sound = sound_fixture()
      update_attrs = %{name: "some updated name", speed: "456.7"}

      assert {:ok, %Sound{} = sound} = Audio.update_sound(sound, update_attrs)
      assert sound.name == "some updated name"
      assert sound.speed == Decimal.new("456.7")
    end

    test "update_sound/2 with invalid data returns error changeset" do
      sound = sound_fixture()
      assert {:error, %Ecto.Changeset{}} = Audio.update_sound(sound, @invalid_attrs)
      assert sound == Audio.get_sound!(sound.id)
    end

    test "delete_sound/1 deletes the sound" do
      sound = sound_fixture()
      assert {:ok, %Sound{}} = Audio.delete_sound(sound)
      assert_raise Ecto.NoResultsError, fn -> Audio.get_sound!(sound.id) end
    end

    test "change_sound/1 returns a sound changeset" do
      sound = sound_fixture()
      assert %Ecto.Changeset{} = Audio.change_sound(sound)
    end
  end

  describe "songs" do
    @invalid_attrs %{name: nil}

    test "list_songs/0 returns all songs" do
      song = song_fixture()
      assert Audio.list_songs() == [song]
    end

    test "get_song!/1 returns the song with given id" do
      song = song_fixture()
      assert Audio.get_song!(song.id) == song
    end

    test "create_song/1 with valid data creates a song" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Song{} = song} = Audio.create_song(valid_attrs)
      assert song.name == "some name"
    end

    test "create_song/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Audio.create_song(@invalid_attrs)
    end

    test "update_song/2 with valid data updates the song" do
      song = song_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Song{} = song} = Audio.update_song(song, update_attrs)
      assert song.name == "some updated name"
    end

    test "update_song/2 with invalid data returns error changeset" do
      song = song_fixture()
      assert {:error, %Ecto.Changeset{}} = Audio.update_song(song, @invalid_attrs)
      assert song == Audio.get_song!(song.id)
    end

    test "delete_song/1 deletes the song" do
      song = song_fixture()
      assert {:ok, %Song{}} = Audio.delete_song(song)
      assert_raise Ecto.NoResultsError, fn -> Audio.get_song!(song.id) end
    end

    test "change_song/1 returns a song changeset" do
      song = song_fixture()
      assert %Ecto.Changeset{} = Audio.change_song(song)
    end
  end

  describe "tracks" do
    @invalid_attrs %{
      song_id: nil,
      name: nil
    }

    test "list_tracks/0 returns all tracks" do
      track = track_fixture(song_fixture())
      assert Audio.list_tracks() == [track]
    end

    test "get_track!/1 returns the track with given id" do
      track = track_fixture(song_fixture())
      assert Audio.get_track!(track.id) == track
    end

    test "create_track/1 with valid data creates a track" do
      %Song{id: song_id} = song_fixture()

      valid_attrs = %{
        song_id: song_id,
        name: "some name",
        num_chunks: 99
      }

      assert {:ok, %Track{} = track} = Audio.create_track(valid_attrs)
      assert track.song_id == song_id
      assert track.name == "some name"
    end

    test "create_track/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Audio.create_track(@invalid_attrs)
    end

    test "update_track/2 with valid data updates the track" do
      track = track_fixture(song_fixture())

      update_attrs = %{
        name: "some updated name"
      }

      assert {:ok, %Track{} = track} = Audio.update_track(track, update_attrs)
      assert track.name == "some updated name"
    end

    test "update_track/2 with invalid data returns error changeset" do
      track = track_fixture(song_fixture())
      assert {:error, %Ecto.Changeset{}} = Audio.update_track(track, @invalid_attrs)
      assert track == Audio.get_track!(track.id)
    end

    test "delete_track/1 deletes the track" do
      track = track_fixture(song_fixture())
      assert {:ok, %Track{}} = Audio.delete_track(track)
      assert_raise Ecto.NoResultsError, fn -> Audio.get_track!(track.id) end
    end

    test "change_track/1 returns a track changeset" do
      track = track_fixture(song_fixture())
      assert %Ecto.Changeset{} = Audio.change_track(track)
    end
  end

  describe "chunks" do
    @invalid_attrs %{
      index: nil,
      value: nil
    }

    test "list_chunks/0 returns all chunks" do
      chunk = chunk_fixture(track_fixture(song_fixture()))
      assert Audio.list_chunks() == [chunk]
    end

    test "get_chunk!/1 returns the chunk with given id" do
      chunk = chunk_fixture(track_fixture(song_fixture()))
      assert Audio.get_chunk!(chunk.id) == chunk
    end

    test "create_chunk/1 with valid data creates a chunk" do
      %Track{id: track_id} = track_fixture(song_fixture())

      valid_attrs = %{
        track_id: track_id,
        index: 22,
        value: List.duplicate(22.5, 1000)
      }

      assert {:ok, %Chunk{} = chunk} = Audio.create_chunk(valid_attrs)
      assert chunk.value == Pgvector.HalfVector.new(List.duplicate(22.5, 1000))
    end

    test "create_chunk/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Audio.create_chunk(@invalid_attrs)
    end

    test "update_chunk/2 with valid data updates the chunk" do
      chunk = chunk_fixture(track_fixture(song_fixture()))

      update_attrs = %{
        index: 33,
        value: List.duplicate(33.5, 1000)
      }

      assert {:ok, %Chunk{} = chunk} = Audio.update_chunk(chunk, update_attrs)
      assert chunk.index == 33
      assert chunk.value == Pgvector.HalfVector.new(List.duplicate(33.5, 1000))
    end

    test "update_chunk/2 with invalid data returns error changeset" do
      chunk = chunk_fixture(track_fixture(song_fixture()))
      assert {:error, %Ecto.Changeset{}} = Audio.update_chunk(chunk, @invalid_attrs)
      assert chunk == Audio.get_chunk!(chunk.id)
    end

    test "delete_chunk/1 deletes the chunk" do
      chunk = chunk_fixture(track_fixture(song_fixture()))
      assert {:ok, %Chunk{}} = Audio.delete_chunk(chunk)
      assert_raise Ecto.NoResultsError, fn -> Audio.get_chunk!(chunk.id) end
    end

    test "change_chunk/1 returns a chunk changeset" do
      chunk = chunk_fixture(track_fixture(song_fixture()))
      assert %Ecto.Changeset{} = Audio.change_chunk(chunk)
    end
  end
end
