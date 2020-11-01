defmodule Radio.Media.Song do
  use Ecto.Schema
  import Ecto.Changeset

  alias Radio.Media.Album

  schema "songs" do
    field :art, :string
    field :audio_channels, :integer
    field :audio_codec, :string
    field :bitrate, :integer
    field :container, :string
    field :duration, :integer
    field :file, :string
    field :guid, :string
    field :index, :integer
    field :key, :string
    field :size, :integer
    field :summary, :string
    field :thumb, :string
    field :title, :string

    belongs_to :album, Album

    timestamps()
  end

  @doc false
  def changeset(song, attrs) do
    song
    |> cast(attrs, [
      :album_id,
      :key,
      :guid,
      :title,
      :summary,
      :index,
      :thumb,
      :art,
      :duration,
      :bitrate,
      :audio_channels,
      :audio_codec,
      :container,
      :file,
      :size
    ])
    |> validate_required([
      :album_id,
      :key,
      :bitrate,
      :audio_channels,
      :audio_codec,
      :container,
      :file,
      :size
    ])
  end
end
