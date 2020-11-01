defmodule Radio.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :rating_key, :string
      add :key, :string
      add :guid, :string
      add :name, :string
      add :summary, :text
      add :index, :integer
      add :thumb, :string
      add :art, :string
      add :country, {:array, :string}

      timestamps()
    end

    create unique_index(:artists, [:key])
  end
end
