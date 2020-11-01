defmodule Radio.Repo.Migrations.CreateStations do
  use Ecto.Migration

  def change do
    create table(:stations) do
      add :name, :string
      add :active, :boolean, default: true
      add :auto_play, :boolean, default: true

      timestamps()
    end

    create index(:stations, [:active])
  end
end
