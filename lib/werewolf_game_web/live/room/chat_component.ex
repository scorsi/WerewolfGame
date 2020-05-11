defmodule WerewolfGameWeb.Room.ChatComponent do
  use WerewolfGameWeb, :live_component

  alias WerewolfGame.Room

  @impl true
  def render(assigns) do
    Phoenix.View.render(WerewolfGameWeb.RoomView, "chat_component.html", assigns)
  end

  def mount(socket) do
    {:ok, assign(socket, text: "")}
  end

  @impl true
  def handle_event(
        "post_message",
        %{
          "message" => %{
            "text" => text
          }
        },
        %{
          assigns: %{
            current_user: current_user,
            room_id: room_id
          }
        } = socket
      ) do
    if String.length(text) > 0 do
      room_id
      |> Room.post_message(text, current_user)
    end
    {:noreply, socket}
  end
end
