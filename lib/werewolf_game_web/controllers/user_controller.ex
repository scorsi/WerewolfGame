defmodule WerewolfGameWeb.UserController do
  @moduledoc false

  require Logger

  use WerewolfGameWeb, :controller

  alias Pow.Plus, as: PowPlug
  alias WerewolfGameWeb.HomeLive

  def register(conn, _params) do
    changeset = PowPlug.change_user(conn)

    render(conn, "register.html", changeset: changeset)
  end

  def register_post(conn, %{"user" => user_params}) do
    conn
    |> PowPlug.create_user(user_params)
    |> case do
      {:ok, user, conn} ->
        conn
        |> PowPlug.update_user(user_params)
        |> case do
          {:ok, _user, conn} ->
            conn
            |> put_flash(:info, "Welcome!")
            |> redirect(to: Routes.live_path(conn, HomeLive))

          {:error, _, conn} ->
            redirect(conn, to: Routes.live_path(conn, HomeLive))
        end

      {:error, changeset, conn} ->
        conn
        |> put_flash(
          :info,
          "Invalid email, nickname or password. Or this email/nickname are already used."
        )
        |> render("register.html", changeset: changeset)
    end
  end

  def login(conn, _params) do
    changeset = PowPlug.change_user(conn)

    render(conn, "login.html", changeset: changeset)
  end

  def login_post(conn, %{"user" => user_params}) do
    conn
    |> PowPlug.authenticate_user(user_params)
    |> case do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> redirect(to: Routes.live_path(conn, HomeLive))

      {:error, conn} ->
        changeset = PowPlug.change_user(conn, conn.params["user"])

        conn
        |> put_flash(:info, "Invalid email or password")
        |> render("login.html", changeset: changeset)
    end
  end

  def logout(conn, _params) do
    conn
    |> PowPlug.delete()
    |> redirect(to: Routes.live_path(conn, HomeLive))
  end
end
