defmodule WerewolfGame.Application do
  @moduledoc false

  use Application

  alias Phoenix.PubSub
  alias Pow.Store.Backend.MnesiaCache, as: PowMnesiaCache
  alias WerewolfGame.{Presence, PublicRoomAgent, Repo, RoomRegistry, RoomSupervisor}
  alias WerewolfGame.PubSub, as: ApplicationPubSub
  alias WerewolfGame.Supervisor, as: ApplicationSupervisor
  alias WerewolfGameWeb.{Endpoint, Telemetry}

  def start(_type, _args) do
    children = [
      Repo,
      Telemetry,
      {PubSub, name: ApplicationPubSub},
      {Registry, keys: :unique, name: RoomRegistry},
      {DynamicSupervisor, strategy: :one_for_one, name: RoomSupervisor},
      PublicRoomAgent,
      Presence,
      Endpoint,
      PowMnesiaCache
    ]

    opts = [strategy: :one_for_one, name: ApplicationSupervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Endpoint.config_change(changed, removed)
    :ok
  end
end
