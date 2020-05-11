defmodule WerewolfGameWeb.Room.ChatComponent do
  @moduledoc false

  use WerewolfGameWeb, :live_component

  alias Phoenix.View
  alias WerewolfGame.Room
  alias WerewolfGameWeb.RoomView

  @impl true
  def render(assigns) do
    View.render(RoomView, "chat_component.html", assigns)
  end

  @impl true
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
