defmodule Radio.Repo.Migrations.CreatePlayItems do
  use Ecto.Migration

  def change do
    create table(:play_items) do
      add :played, :boolean, default: false, null: false
      add :start_time, :utc_datetime
      add :end_time, :utc_datetime
      add :song_id, references(:songs, on_delete: :delete_all)
      add :station_id, references(:stations, on_delete: :delete_all)
      add :album_id, references(:albums, on_delete: :delete_all)

      timestamps()
    end

    create index(:play_items, [:song_id])
    create index(:play_items, [:station_id])
    create index(:play_items, [:album_id])
    create index(:play_items, [:start_time])
    create index(:play_items, [:end_time])
  end
end
