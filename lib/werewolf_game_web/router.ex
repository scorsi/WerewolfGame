defmodule WerewolfGameWeb.Router do
  require Logger

  use WerewolfGameWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {WerewolfGameWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :protected do
    plug Pow.Plug.RequireAuthenticated,
      error_handler: WerewolfGameWeb.AuthErrorHandler
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: WerewolfGameWeb.AuthErrorHandler
  end

  scope "/", WerewolfGameWeb do
    pipe_through [:browser]

    live "/", HomeLive
  end

  scope "/", WerewolfGameWeb do
    pipe_through [:browser, :not_authenticated]

    get "/register", UserController, :register, as: :register
    post "/register", UserController, :register_post, as: :register
    get "/login", UserController, :login, as: :login
    post "/login", UserController, :login_post, as: :login
  end

  scope "/", WerewolfGameWeb do
    pipe_through [:browser, :protected]

    delete "/logout", UserController, :logout, as: :logout

    live "/room", RoomLive
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WerewolfGameWeb.Telemetry
    end
  end
end
