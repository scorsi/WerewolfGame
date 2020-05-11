defmodule WerewolfGameWeb.Room.MembersListComponent do
  @moduledoc false

  use WerewolfGameWeb, :live_component

  alias Phoenix.View
  alias WerewolfGameWeb.RoomView

  @impl true
  def render(assigns) do
    View.render(RoomView, "members_list_component.html", assigns)
  end
end
