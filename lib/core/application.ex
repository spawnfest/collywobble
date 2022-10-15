defmodule Core.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Core.Repo,
      Web.Telemetry,
      {Phoenix.PubSub, name: Core.PubSub},
      Web.Endpoint,
      {Registry, keys: :unique, name: Registry.Pads}
    ]

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
