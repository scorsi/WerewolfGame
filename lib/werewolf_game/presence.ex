defmodule WerewolfGame.Presence do
  @moduledoc false

  use Phoenix.Presence,
    otp_app: :werewolf_game,
    pubsub_server: WerewolfGame.PubSub
end
