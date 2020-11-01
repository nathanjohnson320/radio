defmodule Radio.Repo.Migrations.AddGenreStations do
  use Ecto.Migration

  def change do
    create table(:station_genres) do
      add :station_id, references(:stations, on_delete: :delete_all)
      add :genre_id, references(:genres, on_delete: :delete_all)
    end

    create index(:station_genres, [:station_id])
    create index(:station_genres, [:genre_id])
  end
end
