defmodule Conductor.Demo.Instruction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "instructions" do
    field :name, :string
    field :value, :string
  end

  def changeset(instruction, attrs) do
    instruction
    |> cast(attrs, [:name, :value])
    |> validate_required([:name])
  end
end
