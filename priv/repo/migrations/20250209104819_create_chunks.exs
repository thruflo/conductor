defmodule Conductor.Repo.Migrations.CreateChunks do
  use Ecto.Migration

  def change do
    create table(:chunks) do
      add :index, :integer, null: false
      add :value, :halfvec, size: 1_000, null: false

      add :track_id, references(:tracks, on_delete: :delete_all), null: false
    end

    create index(:chunks, [:track_id])
  end
end
