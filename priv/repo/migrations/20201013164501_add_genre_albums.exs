defmodule Radio.Repo.Migrations.AddGenreAlbums do
  use Ecto.Migration

  def change do
    create table(:album_genres) do
      add :album_id, references(:albums, on_delete: :delete_all)
      add :genre_id, references(:genres, on_delete: :delete_all)
    end

    create index(:album_genres, [:album_id])
    create index(:album_genres, [:genre_id])
  end
end
