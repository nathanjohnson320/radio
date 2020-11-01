defmodule Radio.Repo.Migrations.AddGenreArtists do
  use Ecto.Migration

  def change do
    create table(:artist_genres) do
      add :artist_id, references(:artists, on_delete: :delete_all)
      add :genre_id, references(:genres, on_delete: :delete_all)
    end

    create index(:artist_genres, [:artist_id])
    create index(:artist_genres, [:genre_id])
  end
end
