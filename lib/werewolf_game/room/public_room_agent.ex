defmodule WerewolfGame.PublicRoomAgent do
  @moduledoc false

  alias WerewolfGame.{PublicRoom, PubSub}

  use Agent

  @topic "public_room"

  def subscribe() do
    PubSub.subscribe(@topic)
  end

  def start_link(_initial_value) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def list_rooms() do
    Agent.get(__MODULE__, & &1)
  end

  def actualize_room(room) do
    room =
      room
      |> PublicRoom.create_from_room()

    Agent.update(
      __MODULE__,
      &(&1
        |> Map.put(room.id, room))
    )

    PubSub.broadcast(@topic, :actualized_room, room)
    room
  end

  def register_room(room) do
    room =
      room
      |> PublicRoom.create_from_room()

    Agent.update(
      __MODULE__,
      &(&1
        |> Map.put(room.id, room))
    )

    PubSub.broadcast(@topic, :registered_room, room)
    room
  end

  def unregister_room(room) do
    room =
      room
      |> PublicRoom.create_from_room()

    Agent.update(
      __MODULE__,
      &(&1
        |> Map.delete(room.id))
    )

    PubSub.broadcast(@topic, :unregistered_room, room)
    room
  end
end
