defmodule WerewolfGameWeb.AuthErrorHandler do
  use WerewolfGameWeb, :controller

  def call(conn, :not_authenticated) do
    conn
    |> put_flash(:error, "You've to be authenticated first")
    # |> redirect(to: Routes.login_path(conn, :login))
  end

  def call(conn, :already_authenticated) do
    conn
    |> put_flash(:error, "You're already authenticated")
    # |> redirect(to: Routes.home_path(conn, :index))
  end
end
