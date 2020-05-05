defmodule WerewolfGame.Presence do
  use Phoenix.Presence,
    otp_app: :werewolf_game,
    pubsub_server: WerewolfGame.PubSub
end
