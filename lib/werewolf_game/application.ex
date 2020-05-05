defmodule WerewolfGame.Application do
  use Application

  def start(_type, _args) do
    children = [
      WerewolfGame.Repo,
      WerewolfGameWeb.Telemetry,
      WerewolfGame.Manager,
      {Phoenix.PubSub, name: WerewolfGame.PubSub},
      WerewolfGame.Presence,
      WerewolfGameWeb.Endpoint,
      Pow.Store.Backend.MnesiaCache,
    ]

    opts = [strategy: :one_for_one, name: WerewolfGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    WerewolfGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
