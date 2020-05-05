defmodule WerewolfGameWeb.HomeLive do
  use WerewolfGameWeb, :live_view

  alias WerewolfGame.{PubSub, Manager}

  @impl true
  def render(assigns) do
    Phoenix.View.render(WerewolfGameWeb.HomeView, "index.html", assigns)
  end

  @impl true
  def mount(_params, %{"current_user" => current_user}, socket) do
    PubSub.subscribe("rooms")
    {:ok, rooms} = Manager.list_rooms()
    {:ok, assign(socket, current_user: current_user, rooms: rooms)}
  end

  @impl true
  def handle_info({:new_room, room}, %{"assigns" => %{rooms: rooms}} = socket) do
    {:noreply, assign(socket, rooms: [rooms | room])}
  end
end
