defmodule WerewolfGame.Manager do
  use GenServer

  alias WerewolfGame.Manager.Room

  def start_link(_state \\ nil) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    table = :ets.new(:werewolf_game_room, [:set, :private])

    {:ok, Map.put(state, :table, table)}
  end

  @impl true
  def terminate(_reason, state) do
    :ets.delete(state.table)
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

  @spec get_room(String.t()) :: {:ok, Room} | {:error, any}
  def get_room(room_name),
    do: GenServer.call(__MODULE__, {:get_room, room_name})

  defp get_room(table, room_name) do
    case :ets.lookup(table, room_name) do
      [] -> {:error, :no_room_found}
      [room] -> {:ok, deserialize(room)}
    end
  end

  @spec create_room(Room) :: {:ok, Room} | {:error, any}
  def create_room(room),
    do: GenServer.call(__MODULE__, {:create_room, room})

  defp create_room(table, %Room{name: room_name} = room) do
    if String.length(room_name) == 0 do
      {:error, :invalid_room_name}
    else
      case :ets.insert_new(table, serialize(room)) do
        true -> {:ok, room}
        false -> {:error, :room_already_exists}
      end
    end
  end

  @spec update_room(String.t(), Room) :: {:ok, Room} | {:error, any}
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
        :ets.insert(table, serialize(room))
        {:ok, room}
    end
  end

  @spec delete_room(String.t()) :: {:ok, Room} | {:error, any}
  def delete_room(room_name),
    do: GenServer.call(__MODULE__, {:delete_room, room_name})

  defp delete_room(table, room_name) do
    case get_room(table, room_name) do
      {:ok, room} ->
        :ets.delete(table, room_name)
        {:ok, room}

      error ->
        error
    end
  end

  @spec list_rooms() :: {:ok, [Room]} | {:error, any}
  def list_rooms(),
    do: GenServer.call(__MODULE__, {:list_rooms})

  defp list_rooms(table) do
    {
      :ok,
      :ets.tab2list(table)
      |> Enum.map(&deserialize(&1))
    }
  end

  defp serialize(%Room{name: name, members: members, owner: owner}) do
    {name, members, owner}
  end

  defp deserialize({name, members, owner}) do
    %Room{name: name, members: members, owner: owner}
  end
end
