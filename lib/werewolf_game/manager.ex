defmodule WerewolfGame.Manager do
  use GenServer

  alias WerewolfGame.Manager.Room

  def start_link(_state \\ nil) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)

    {:ok, table} =
      Ets.Set.new(ordered: true, read_concurrency: true, compressed: false, protection: :private)

    {:ok, Map.put(state, :table, table)}
  end

  @impl true
  def terminate(_reason, state) do
    Ets.Set.delete(state.table)
    state
  end

  @impl true
  def handle_call({:get_room, room_name}, _from, state),
    do: {:reply, get_room(state.table, room_name), state}

  @impl true
  def handle_call({:create_room, room}, _from, state),
    do: {:reply, create_room(state.table, room), state}

  @impl true
  def handle_call({:update_room, room_name, room}, _from, state),
    do: {:reply, update_room(state.table, room_name, room), state}

  @impl true
  def handle_call({:delete_room, room_name}, _from, state),
    do: {:reply, delete_room(state.table, room_name), state}

  @impl true
  def handle_call({:list_rooms}, _from, state),
    do: {:reply, list_rooms(state.table), state}

  def get_room(room_name),
    do: GenServer.call(__MODULE__, {:get_room, room_name})

  defp get_room(table, room_name) do
    case Ets.Set.get(table, room_name) do
      {:ok, nil} -> {:error, :no_room_found}
      {:ok, room} -> {:ok, deserialize(room)}
      error -> error
    end
  end

  def create_room(room),
    do: GenServer.call(__MODULE__, {:create_room, room})

  defp create_room(table, %Room{name: room_name} = room) do
    case get_room(table, room_name) do
      {:error, :no_room_found} ->
        case Ets.Set.put_new(table, serialize(room)) do
          {:ok, _} -> {:ok, room}
          error -> error
        end

      {:ok, _} ->
        {:error, :room_already_exists}

      error ->
        error
    end
  end

  def update_room(room_name, room),
    do: GenServer.call(__MODULE__, {:update_room, room_name, room})

  defp update_room(table, room_name, room) do
    case room_name != room.name do
      true ->
        case delete_room(table, room_name) do
          {:ok, _} -> create_room(table, room)
          error -> error
        end

      false ->
        case Ets.Set.put(table, serialize(room)) do
          {:ok, _} -> {:ok, room}
          error -> error
        end
    end
  end

  def delete_room(room_name),
    do: GenServer.call(__MODULE__, {:delete_room, room_name})

  defp delete_room(table, room_name) do
    case get_room(table, room_name) do
      {:ok, room} ->
        case Ets.Set.delete(table, room_name) do
          {:ok, _} -> {:ok, room}
          error -> error
        end

      error ->
        error
    end
  end

  def list_rooms(),
    do: GenServer.call(__MODULE__, {:list_rooms})

  defp list_rooms(table) do
    case Ets.Set.to_list(table) do
      {:ok, rooms} -> {:ok, Enum.map(rooms, &deserialize(&1))}
      error -> error
    end
  end

  defp serialize(%Room{name: name, members: members, owner: owner}) do
    {name, members, owner}
  end

  defp deserialize({name, members, owner}) do
    %Room{name: name, members: members, owner: owner}
  end
end
