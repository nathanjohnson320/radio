# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Radio.Repo.insert!(%Radio.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
artist =
  Radio.Repo.insert!(%Radio.Media.Artist{
    name: "Live",
    key: "live"
  })

album =
  Radio.Repo.insert!(%Radio.Media.Album{
    title: "Live",
    key: "live",
    artist_id: artist.id
  })

Radio.Repo.insert!(%Radio.Media.Song{
  album_id: album.id,
  key: "live",
  bitrate: 192,
  audio_channels: 2,
  audio_codec: "mp3",
  container: "mp3",
  file: "live",
  size: 0
})

Plex.sync()
