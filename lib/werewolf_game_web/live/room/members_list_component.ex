defmodule WerewolfGameWeb.Room.MembersListComponent do
  use WerewolfGameWeb, :live_component

  @impl true
  def render(assigns) do
    Phoenix.View.render(WerewolfGameWeb.RoomView, "members_list_component.html", assigns)
  end
end
