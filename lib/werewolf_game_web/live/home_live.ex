defmodule WerewolfGameWeb.HomeLive do
  @moduledoc false

  use WerewolfGameWeb, :live_view
  use WerewolfGameWeb.LiveViewPowHelper

  alias Phoenix.View
  alias WerewolfGame.PublicRoomAgent
  alias WerewolfGameWeb.HomeView

  @impl true
  def render(assigns) do
    View.render(HomeView, "index.html", assigns)
  end

  @impl true
  def mount(_params, session, socket) do
    PublicRoomAgent.subscribe()
    socket = maybe_assign_current_user(socket, session)
    {:ok, assign(socket, rooms: PublicRoomAgent.list_rooms(), page_title: "Accueil")}
  end

  @impl true
  def handle_info(
        %{event: :actualized_room, payload: room},
        %{
          assigns: %{
            rooms: rooms
          }
        } = socket
      ) do
    {
      :noreply,
      assign(
        socket,
        rooms:
          rooms
          |> Map.put(room.id, room)
      )
    }
  end

  @impl true
  def handle_info(
        %{event: :registered_room, payload: room},
        %{
          assigns: %{
            rooms: rooms
          }
        } = socket
      ) do
    {
      :noreply,
      assign(
        socket,
        rooms:
          rooms
          |> Map.put(room.id, room)
      )
    }
  end

  @impl true
  def handle_info(
        %{event: :unregistered_room, payload: room},
        %{
          assigns: %{
            rooms: rooms
          }
        } = socket
      ) do
    {
      :noreply,
      assign(
        socket,
        rooms:
          rooms
          |> Map.delete(room.id)
      )
    }
  end
end
