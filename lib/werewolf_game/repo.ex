defmodule WerewolfGame.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :werewolf_game,
    adapter: Ecto.Adapters.Postgres
end
