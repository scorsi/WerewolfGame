defmodule WerewolfGameWeb.RoomLive do
  require Logger
  use WerewolfGameWeb.LiveViewPowHelper

  use WerewolfGameWeb, :live_view

  alias WerewolfGame.Room

  @impl true
  def render(%{room: room} = assigns) do
    case room do
      nil ->
        Phoenix.View.render(WerewolfGameWeb.RoomView, "not_found.html", assigns)

      _ ->
        Phoenix.View.render(WerewolfGameWeb.RoomView, "index.html", assigns)
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket = maybe_assign_current_user(socket, session)
    {:ok, socket}
  end

  @impl true
  def terminate(_reason, %{assigns: %{current_user: current_user, room: room}} = socket) do
    room
    |> Room.unregister_user(current_user)

    socket
  end

  @impl true
  def handle_params(
        %{"id" => id} = _params,
        _uri,
        %{assigns: %{current_user: current_user}} = socket
      ) do
    case Room.get_info(id) do
      nil ->
        {:noreply, assign(socket, room: nil)}

      room ->
        Process.send_after(self(), %{event: :join}, 100)
        {:noreply, assign(socket, room: room, is_owner?: current_user.id == room.owner.id)}
    end
  end

  @impl true
  def handle_params(
        %{} = _params,
        _uri,
        %{assigns: %{current_user: current_user}} = socket
      ) do
    room =
      %Room{name: "Room de #{current_user.nickname}", owner: current_user}
      |> Room.create_room()

    {:noreply, redirect(socket, to: Routes.live_path(socket, __MODULE__, id: room.id))}
  end

  @impl true
  def handle_info(
        %{event: :join},
        %{assigns: %{current_user: current_user, room: room}} = socket
      ) do
    room
    |> Room.subscribe()
    |> Room.register_user(current_user)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: :registered_user, payload: user},
        %{assigns: %{room: room}} = socket
      ) do
    {:noreply, assign(socket, room: %Room{room | members: room.members ++ [user]})}
  end

  @impl true
  def handle_info(
        %{event: :unregistered_user, payload: user},
        %{assigns: %{room: room}} = socket
      ) do
    {:noreply,
     assign(socket,
       room: %Room{room | members: room.members |> Enum.reject(fn u -> u.id == user.id end)}
     )}
  end
end
