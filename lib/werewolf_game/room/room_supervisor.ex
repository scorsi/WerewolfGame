defmodule WerewolfGame.RoomSupervisor do
  use DynamicSupervisor

  alias WerewolfGame.Room

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_room(%Room{} = room) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {WerewolfGame.Room, initial_state: room, name: get_process_via(room)}
    )
    room
  end

  def kill_room(room) do
    case lookup_process(room) do
      nil -> :ok
      pid -> DynamicSupervisor.terminate_child(__MODULE__, pid)
    end
    room
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def get_process_via(%Room{} = room) do
    {:via, Registry, {WerewolfGame.RoomRegistry, "room:#{room.id}"}}
  end

  def get_process_via(room_id) do
    {:via, Registry, {WerewolfGame.RoomRegistry, "room:#{room_id}"}}
  end

  def lookup_process(%Room{} = room) do
    case Registry.lookup(WerewolfGame.RoomRegistry, "room:#{room.id}") do
      [] -> nil
      [{pid, _}] -> pid
    end
  end

  def lookup_process(room_id) do
    case Registry.lookup(WerewolfGame.RoomRegistry, "room:#{room_id}") do
      [] -> nil
      [{pid, _}] -> pid
    end
  end

  def call_process(room, message) do
    case lookup_process(room) do
      nil -> nil
      pid -> GenServer.call(pid, message)
    end
  end

  def cast_process(room, message) do
    case lookup_process(room) do
      pid -> GenServer.cast(pid, message)
    end
    room
  end
end
