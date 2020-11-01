defmodule Radio.Media.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radio.Media.Genre

  schema "artists" do
    field :art, :string
    field :country, {:array, :string}
    field :guid, :string
    field :index, :integer
    field :key, :string
    field :name, :string
    field :rating_key, :string
    field :summary, :string
    field :thumb, :string

    many_to_many(
      :genres,
      Genre,
      join_through: "artist_genres",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(artist, attrs, genres) do
    artist
    |> cast(attrs, [
      :rating_key,
      :key,
      :guid,
      :name,
      :summary,
      :index,
      :thumb,
      :art,
      :country
    ])
    |> validate_required([
      :key
    ])
    |> put_assoc(:genres, genres)
  end
end
