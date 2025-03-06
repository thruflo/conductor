defmodule Conductor.Audio.Chunk do
  use Conductor, :schema

  schema "chunks" do
    belongs_to :track, Conductor.Audio.Track

    field :index, :integer
    field :value, Pgvector.Ecto.HalfVector
  end

  def changeset(chunk, attrs) do
    chunk
    |> cast(attrs, [:track_id, :index, :value])
    |> validate_required([:track_id, :index, :value])
    |> foreign_key_constraint(:track_id)
  end
end
