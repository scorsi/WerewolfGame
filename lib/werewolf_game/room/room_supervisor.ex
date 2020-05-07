defmodule WerewolfGame.RoomSupervisor do
  use DynamicSupervisor

  alias WerewolfGame.RoomRegistry

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_room(room) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {WerewolfGame.Room, initial_room: room, name: RoomRegistry.get_process_name(room.id)}
    )

    room
  end

  def kill_room(room) do
    case Registry.lookup(WerewolfGame.RoomRegistry, room.id) do
      [] ->
        room

      [{pid, _}] ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)
        room
    end
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
