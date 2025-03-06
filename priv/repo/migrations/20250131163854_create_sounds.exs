defmodule Conductor.Repo.Migrations.CreateSounds do
  use Ecto.Migration

  def change do
    create table(:sounds) do
      add :name, :string, null: false
      add :speed, :decimal
    end
  end
end
