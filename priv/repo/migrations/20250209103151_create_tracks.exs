defmodule Conductor.Repo.Migrations.CreateTracks do
  use Ecto.Migration

  def change do
    create table(:tracks) do
      add :name, :string, null: false
      add :num_chunks, :integer, default: 0, null: false

      add :song_id, references(:songs, on_delete: :delete_all), null: false
    end

    create unique_index(:tracks, [:song_id, :name])
  end
end
