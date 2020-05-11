use Mix.Config

config :werewolf_game,
  ecto_repos: [WerewolfGame.Repo]

config :werewolf_game,
       :pow,
       user: WerewolfGame.Auth.User,
       repo: WerewolfGame.Repo,
       web_module: WerewolfGameWeb,
       cache_store_backend: Pow.Store.Backend.MnesiaCache

config :werewolf_game,
       WerewolfGameWeb.Endpoint,
       url: [
         host: "localhost"
       ],
       secret_key_base: "rt5U0qqM/fQpINi6ZPDqyAHUD8mYpUlDVU5KsUD3oXu4XHemLQs/8BKs5PzTdbi5",
       render_errors: [
         view: WerewolfGameWeb.ErrorView,
         accepts: ~w(html json),
         layout: false
       ],
       pubsub_server: WerewolfGame.PubSub,
       live_view: [
         signing_salt: "Yt9+Rt0h"
       ]

config :logger,
       :console,
       format: "$time $metadata[$level] $message\n",
       metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"
