defmodule WerewolfGameWeb.UserController do
  require Logger

  use WerewolfGameWeb, :controller

  def register(conn, _params) do
    changeset = Pow.Plug.change_user(conn)

    render(conn, "register.html", changeset: changeset)
  end

  def register_post(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.create_user(user_params)
    |> case do
         {:ok, user, conn} ->
           conn
           |> Pow.Plug.update_user(user_params)
           |> case do
                {:ok, _user, conn} ->
                  conn
                  |> put_flash(:info, "Welcome!")
                  |> redirect(to: Routes.live_path(conn, WerewolfGameWeb.HomeLive))

                {:error, _, conn} ->
                  redirect(conn, to: Routes.live_path(conn, WerewolfGameWeb.HomeLive))
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
    changeset = Pow.Plug.change_user(conn)

    render(conn, "login.html", changeset: changeset)
  end

  def login_post(conn, %{"user" => user_params}) do
    conn
    |> Pow.Plug.authenticate_user(user_params)
    |> case do
         {:ok, conn} ->
           conn
           |> put_flash(:info, "Welcome back!")
           |> redirect(to: Routes.live_path(conn, WerewolfGameWeb.HomeLive))

         {:error, conn} ->
           changeset = Pow.Plug.change_user(conn, conn.params["user"])

           conn
           |> put_flash(:info, "Invalid email or password")
           |> render("login.html", changeset: changeset)
       end
  end

  def logout(conn, _params) do
    conn
    |> Pow.Plug.delete()
    |> redirect(to: Routes.live_path(conn, WerewolfGameWeb.HomeLive))
  end
end
