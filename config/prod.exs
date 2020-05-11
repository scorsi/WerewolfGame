use Mix.Config

config :werewolf_game,
       WerewolfGameWeb.Endpoint,
       load_from_system_env: true,
       http: [
         port: {:system, "PORT"}
       ],
       url: [
         host: "${APP_NAME}.gigalixirapp.com",
         port: 443
       ],
       server: true,
       secret_key_base: "${SECRET_KEY_BASE}",
       cache_static_manifest: "priv/static/cache_manifest.json",
       version: Mix.Project.config[:version]

config :werewolf_game,
       WerewolfGameWeb.Repo,
       adapter: Ecto.Adapters.Postgres,
       url: "${DATABASE_URL}",
       database: "",
       ssl: true,
       pool_size: 2

config :logger, level: :info

#import_config "prod.secret.exs"
