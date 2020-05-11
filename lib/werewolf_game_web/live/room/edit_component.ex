defmodule WerewolfGameWeb.Room.EditComponent do
  use WerewolfGameWeb, :live_component

  alias WerewolfGame.{Room, GameCharacter}

  @impl true
  def render(assigns) do
    Phoenix.View.render(WerewolfGameWeb.RoomView, "edit_component.html", assigns)
  end

  @impl true
  def mount(socket) do
    {
      :ok,
      assign(
        socket,
        characters:
          GameCharacter.get_all()
          |> Enum.map(fn c -> %{name: c.name, team: c.team} end)
      )
    }
  end

  @impl true
  def update(%{room_id: room_id}, socket) do
    room =
      room_id
      |> Room.get_info()
    {:ok, assign(socket, room_id: room_id, name: room.name, public?: room.public?)}
  end

  @impl true
  def handle_event(
        "save",
        %{
          "room" => %{
            "name" => name,
            "public?" => public?
          }
        },
        %{
          assigns: %{
            room_id: room_id
          }
        } = socket
      ) do
    room_id
    |> Room.update_room(name: name, public?: public?)
    {:noreply, socket}
  end
end
