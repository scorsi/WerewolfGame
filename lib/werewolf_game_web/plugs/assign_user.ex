defmodule WerewolfGameWeb.AssignUser do
  import Plug.Conn

  alias WerewolfGame.Auth.User
  alias WerewolfGame.Repo

  def init(opts), do: opts

  def call(conn, params) do
    case Pow.Plug.current_user(conn) do
      %User{} = user ->
        assign(conn, :current_user, Repo.preload(user, params[:preload] || []))
      _ ->
        assign(conn, :current_use, nil)
    end
  end
end
