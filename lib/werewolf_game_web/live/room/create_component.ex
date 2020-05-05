defmodule WerewolfGameWeb.Room.CreateComponent do
  use WerewolfGameWeb, :live_component

  alias WerewolfGame.{PubSub, Manager, Manager.Room}

  @impl true
  def render(assigns) do
    Phoenix.View.render(WerewolfGameWeb.RoomView, "create_component.html", assigns)
  end

  @impl true
  def handle_event(
        "create_room",
        %{"room" => %{"name" => name}},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    case Manager.create_room(%Room{name: name, owner: 1, members: [1]}) do
      {:ok, room} ->
        PubSub.broadcast("rooms", :new_room, room)
    end

    {:noreply, socket}
  end
end
