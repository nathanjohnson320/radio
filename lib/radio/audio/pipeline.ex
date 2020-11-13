defmodule Radio.Audio.Pipeline do
  use Membrane.Pipeline

  alias Plex
  alias Radio.Station
  alias Radio.Audio.Broadcaster.Sink, as: BroadcastSink
  alias Radio.Media.Song
  alias Membrane.File

  @base_volume Application.get_env(:radio, :base_volume)
  @mount_point Application.get_env(:radio, :mount_point)

  @impl true
  def handle_init(%{song: %Song{} = song, pid: pid, station: station}) do
    children = %{
      file: %File.Source{
        location: String.replace(song.file, @base_volume, @mount_point)
      },
      parser: %Membrane.Element.MPEGAudioParse.Parser{skip_until_frame: true},
      broadcaster: BroadcastSink
    }

    links = [
      link(:file) |> to(:parser) |> to(:broadcaster)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}},
     %{station: station, song: song, pid: pid}}
  end

  @impl true
  def handle_notification(
        {:broadcaster, :complete},
        _element,
        _context,
        %{pid: pid} = state
      ) do
    Station.next(pid, __MODULE__)
    {:ok, state}
  end

  @impl true
  def handle_notification(
        {:broadcaster, {:chunk, chunk}},
        :broadcaster,
        _ctx,
        %{pid: pid} = state
      ) do
    Station.chunk(pid, chunk)
    {:ok, state}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, %{pid: pid} = state) do
    Station.playing(pid)

    {:ok, state}
  end
end
