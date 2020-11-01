defmodule Radio.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :key, :string
      add :guid, :string
      add :title, :string, size: 512
      add :summary, :text
      add :index, :integer
      add :thumb, :string
      add :art, :string
      add :duration, :integer
      add :bitrate, :integer
      add :audio_channels, :integer
      add :audio_codec, :string
      add :container, :string
      add :file, :string, size: 512
      add :size, :integer
      add :album_id, references(:albums, on_delete: :delete_all)

      timestamps()
    end

    create index(:songs, [:album_id])
    create unique_index(:songs, [:key])
    create index(:songs, [:audio_codec])
  end
end
