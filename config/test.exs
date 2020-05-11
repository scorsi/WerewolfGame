use Mix.Config

config :werewolf_game,
       WerewolfGame.Repo,
       username: "postgres",
       password: "postgres",
       database: "werewolf_game_test#{System.get_env("MIX_TEST_PARTITION")}",
       hostname: "localhost",
       pool: Ecto.Adapters.SQL.Sandbox

config :werewolf_game,
       WerewolfGameWeb.Endpoint,
       http: [
         port: 4002
       ],
       server: false

config :logger, level: :warn
