defmodule Radio.Repo.Migrations.CreateAlbums do
  use Ecto.Migration

  def change do
    create table(:albums) do
      add :director, {:array, :string}
      add :art, :string
      add :guid, :string
      add :index, :integer
      add :key, :string
      add :studio, :string
      add :summary, :text
      add :thumb, :string
      add :title, :string
      add :year, :integer
      add :artist_id, references(:artists, on_delete: :delete_all)

      timestamps()
    end

    create index(:albums, [:artist_id])
    create unique_index(:albums, [:key])
  end
end
