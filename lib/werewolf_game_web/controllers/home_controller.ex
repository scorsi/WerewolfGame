defmodule WerewolfGameWeb.HomeController do
  use WerewolfGameWeb, :controller

  plug WerewolfGameWeb.AssignUser

  import Phoenix.LiveView.Controller

  def index(
        %{
          assigns: %{
            current_user: current_user
          }
        } = conn,
        _
      ) do
    live_render(
      conn,
      WerewolfGameWeb.HomeLive,
      session: %{
        "current_user" => current_user
      }
    )
  end
end
