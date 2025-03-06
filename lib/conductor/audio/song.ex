defmodule Conductor.Audio.Song do
  use Conductor, :schema

  schema "songs" do
    field :name, :string

    has_many :tracks, Audio.Track
  end

  def changeset(song, attrs) do
    song
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint([:name])
  end
end
