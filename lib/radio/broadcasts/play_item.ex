defmodule Radio.Broadcasts.PlayItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radio.Broadcasts.Station
  alias Radio.Media.{Album, Song}

  schema "play_items" do
    field :start_time, :utc_datetime
    field :end_time, :utc_datetime
    field :played, :boolean, default: false

    belongs_to :song, Song
    belongs_to :album, Album
    belongs_to :station, Station

    timestamps()
  end

  @doc false
  def changeset(play_item, attrs) do
    play_item
    |> cast(attrs, [
      :played,
      :start_time,
      :end_time,
      :album_id,
      :song_id,
      :station_id
    ])
    |> validate_required([
      :played,
      :album_id,
      :song_id,
      :station_id
    ])
  end
end
