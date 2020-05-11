defmodule WerewolfGameWeb.AuthErrorHandler do
  use WerewolfGameWeb, :controller

  def call(conn, :not_authenticated) do
    conn
    |> put_flash(:error, "You've to be authenticated first")
    |> redirect(to: Routes.live_path(conn, WerewolfGameWeb.HomeLive))
  end

  def call(conn, :already_authenticated) do
    conn
    |> put_flash(:error, "You're already authenticated")
    |> redirect(to: Routes.live_path(conn, WerewolfGameWeb.HomeLive))
  end
end
