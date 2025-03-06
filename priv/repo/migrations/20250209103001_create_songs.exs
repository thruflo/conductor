defmodule Conductor.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :name, :string, null: false
    end

    create unique_index(:songs, [:name])
  end
end
