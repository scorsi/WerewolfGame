defmodule WerewolfGame.Repo do
  use Ecto.Repo,
      otp_app: :werewolf_game,
      adapter: Ecto.Adapters.Postgres
end
