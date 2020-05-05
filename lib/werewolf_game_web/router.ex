defmodule WerewolfGameWeb.Router do
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
      error_handler: CuriousMessengerWeb.AuthErrorHandler
  end

  pipeline :not_authenticated do
    plug Pow.Plug.RequireNotAuthenticated,
      error_handler: CuriousMessengerWeb.AuthErrorHandler
  end

  scope "/", WerewolfGameWeb do
    pipe_through :browser

    get "/", HomeController, :index
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: WerewolfGameWeb.Telemetry
    end
  end
end
