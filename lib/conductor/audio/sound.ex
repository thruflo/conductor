defmodule Conductor.Audio.Sound do
  use Conductor, :schema

  schema "sounds" do
    field :name, :string
    field :speed, :decimal
  end

  def changeset(sound, attrs) do
    sound
    |> cast(attrs, [:name, :speed])
    |> validate_required([:name])
  end
end
