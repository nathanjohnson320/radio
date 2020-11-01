defmodule Radio.Media.Album do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radio.Media.Artist
  alias Radio.Media.Genre

  schema "albums" do
    field :art, :string
    field :director, {:array, :string}
    field :guid, :string
    field :index, :integer
    field :key, :string
    field :studio, :string
    field :summary, :string
    field :thumb, :string
    field :title, :string
    field :year, :integer

    belongs_to :artist, Artist

    many_to_many(
      :genres,
      Genre,
      join_through: "album_genres",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(album, attrs, genres) do
    album
    |> cast(attrs, [
      :artist_id,
      :director,
      :art,
      :guid,
      :index,
      :key,
      :studio,
      :summary,
      :thumb,
      :title,
      :year
    ])
    |> validate_required([
      :artist_id,
      :key
    ])
    |> put_assoc(:genres, genres)
  end
end
