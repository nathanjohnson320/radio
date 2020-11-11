defmodule Radio.Audio.Broadcaster.Sink do
  use Membrane.Sink
  use Ratio

  alias Membrane.{Buffer, Time}
  alias Membrane.Caps.Audio.MPEG

  def_input_pad(:input, caps: MPEG, demand_unit: :buffers)

  @impl true
  def handle_init(_state) do
    {:ok, %{timer_started: false}}
  end

  @impl true
  def handle_playing_to_prepared(_ctx, %{timer_started: true} = state) do
    {{:ok, stop_timer: :timer}, %{state | timer_started: false}}
  end

  def handle_playing_to_prepared(_ctx, state) do
    {:ok, state}
  end

  @impl true
  def handle_start_of_stream(:input, ctx, state) do
    demand_every = Ratio.new(Time.seconds(1), ctx.pads.input.input_buf.preferred_size)

    timer = {:demand_timer, demand_every}
    state = %{state | timer_started: true}

    {{:ok, demand: :input, start_timer: timer}, state}
  end

  @impl true
  def handle_end_of_stream(:input, _ctx, state) do
    notification = {
      :broadcaster,
      :complete
    }

    {{:ok, stop_timer: :demand_timer, notify: notification}, %{state | timer_started: false}}
  end

  @impl true
  def handle_write(:input, %Buffer{payload: payload}, _ctx, state) do
    notification = {:broadcaster, {:chunk, payload}}
    {{:ok, notify: notification}, state}
  end

  @impl true
  def handle_tick(:demand_timer, _ctx, state) do
    {{:ok, demand: :input}, state}
  end
end
