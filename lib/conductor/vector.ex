defmodule Conductor.Vector do
  @moduledoc """
  Convert MP3 files to pgvector compatible vectors.

  Write in `%Chunks{}` to the database.
  """

  alias Conductor.Audio
  alias Conductor.Audio.Track
  alias Conductor.Repo
  alias Ecto.Multi

  def mp3_to_vectors(file_path, chunk_size \\ 1000) do
    file_path
    |> File.read!()
    |> to_chunked_vectors(chunk_size)
  end

  # Converts binary audio data to chunked vectors suitable for pgvector storage.
  #
  # Takes the encoded audio data and:
  # 1. Splits it into chunks of the specified size
  # 2. Normalizes each chunk to float values in range -1.0 to 1.0
  # 3. Formats them for pgvector storage
  #
  # Returns a list of vectors.
  defp to_chunked_vectors(binary_data, chunk_size) do
    # Convert binary to a list of bytes
    bytes = :binary.bin_to_list(binary_data)

    # Calculate how many chunks we'll have
    chunk_count = ceil(length(bytes) / chunk_size)

    # Pad the list if necessary to fit evenly into chunks
    padded_bytes =
      if rem(length(bytes), chunk_size) == 0 do
        bytes
      else
        padding_size = chunk_count * chunk_size - length(bytes)
        bytes ++ List.duplicate(0, padding_size)
      end

    # Split into chunks and convert each chunk to a vector
    padded_bytes
    |> Enum.chunk_every(chunk_size)
    |> Enum.map(fn chunk ->
      # Convert bytes to floats in range -1.0 to 1.0
      # This normalization is important for pgvector storage
      Enum.map(chunk, fn byte ->
        byte / 127.5 - 1.0
      end)
      |> Nx.tensor(type: {:f, 16})
      |> prepare_for_pgvector()
    end)
  end

  # Prepares an NX tensor for storage in pgvector.
  # Converts the tensor to the format expected by pgvector's Ecto.Vector type.
  defp prepare_for_pgvector(tensor) do
    tensor
    |> Nx.to_flat_list()
  end

  @doc """
  Save audio vectors to the database using Ecto.

  Takes a list of vectors and saves each one as a separate `%Chunk{}`.
  """
  def save_vectors_to_track(vectors, %Track{id: track_id} = track) do
    multi =
      Multi.new()
      |> Multi.delete_all(:old_chunks, Ecto.assoc(track, :chunks))
      |> Multi.update(:track, Audio.change_track(track, %{num_chunks: Enum.count(vectors)}))

    vectors
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {vector, index}, multi ->
      key = :"new_chunk_#{index}"

      attrs = %{
        track_id: track_id,
        index: index,
        value: vector
      }

      Multi.insert(multi, key, Audio.init_chunk(attrs))
    end)
    |> Repo.transaction()
  end
end
