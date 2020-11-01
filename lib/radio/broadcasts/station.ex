defmodule Radio.Broadcasts.Station do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radio.Broadcasts.PlayItem
  alias Radio.Media.Genre

  schema "stations" do
    field :name, :string
    field :active, :boolean, default: true
    field :auto_play, :boolean, default: true

    has_many :play_items, PlayItem

    many_to_many(
      :genres,
      Genre,
      join_through: "station_genres",
      on_replace: :delete
    )

    timestamps()
  end

  @doc false
  def changeset(station, attrs, genres) do
    station
    |> cast(attrs, [:name, :active, :auto_play])
    |> validate_required([:name, :active, :auto_play])
    |> put_assoc(:genres, genres)
  end
end
