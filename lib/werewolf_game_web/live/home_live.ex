defmodule WerewolfGameWeb.HomeLive do
  use WerewolfGameWeb, :live_view
  use WerewolfGameWeb.LiveViewPowHelper

  alias WerewolfGame.PublicRoomAgent

  @impl true
  def render(assigns) do
    Phoenix.View.render(WerewolfGameWeb.HomeView, "index.html", assigns)
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
        rooms: rooms
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
        rooms: rooms
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
        rooms: rooms
               |> Map.delete(room.id)
      )
    }
  end
end
