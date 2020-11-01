defmodule Radio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Radio.Repo,
      RadioWeb.Telemetry,
      {Phoenix.PubSub, name: Radio.PubSub},
      RadioWeb.Endpoint,
      {Registry, keys: :unique, name: StationRegistry},
      {Radio.Broadcasts.Supervisor, name: StationSupervisor}
    ]

    opts = [strategy: :one_for_one, name: Radio.Supervisor]
    sup = Supervisor.start_link(children, opts)

    Task.start_link(fn ->
      Radio.Broadcasts.boot_stations()
    end)

    sup
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RadioWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
