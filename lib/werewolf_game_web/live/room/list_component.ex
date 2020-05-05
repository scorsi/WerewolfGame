defmodule WerewolfGameWeb.Room.ListComponent do
  use WerewolfGameWeb, :live_component

  @impl true
  def render(assigns) do
    Phoenix.View.render(WerewolfGameWeb.RoomView, "list_component.html", assigns)
  end
end
