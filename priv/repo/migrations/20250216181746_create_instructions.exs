defmodule Conductor.Repo.Migrations.CreateInstructions do
  use Ecto.Migration

  def change do
    create table(:instructions) do
      add :name, :string
      add :value, :string
    end
  end
end
