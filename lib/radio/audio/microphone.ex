defmodule Radio.Audio.Microphone do
  use Membrane.Pipeline

  alias Membrane.PortAudio
  alias Membrane.FFmpeg
  alias Radio.Station
  alias Radio.Audio.Broadcaster.Sink, as: BroadcastSink

  @device_id Application.get_env(:radio, :device_id)

  @impl true
  def handle_init(%{pid: pid, station: station}) do
    children = [
      mic: %PortAudio.Source{
        endpoint_id: @device_id
      },
      converter: %FFmpeg.SWResample.Converter{
        output_caps: %Membrane.Caps.Audio.Raw{
          format: :s32le,
          sample_rate: 44100,
          channels: 2
        }
      },
      mp3: %Membrane.MP3.Lame.Encoder{},
      broadcaster: BroadcastSink
    ]

    links = [
      link(:mic)
      |> to(:converter)
      |> to(:mp3)
      |> to(:broadcaster)
    ]

    {{:ok, spec: %ParentSpec{children: children, links: links}}, %{station: station, pid: pid}}
  end

  @impl true
  def handle_notification({:broadcaster, :complete}, _element, _context, %{pid: pid} = state) do
    Station.next(pid, __MODULE__)
    {:ok, state}
  end

  @impl true
  def handle_notification({:end_of_stream, :input}, _mp3, _ctx, %{pid: pid} = state) do
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
