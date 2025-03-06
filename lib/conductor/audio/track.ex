defmodule Conductor.Audio.Track do
  use Conductor, :schema

  schema "tracks" do
    belongs_to :song, Audio.Song

    field :name, :string
    field :num_chunks, :integer

    has_many :chunks, Audio.Chunk
  end

  @doc false
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:song_id, :name, :num_chunks])
    |> validate_required([:song_id, :name])
    |> unique_constraint([:song_id, :name])
    |> foreign_key_constraint(:song_id)
  end
end
