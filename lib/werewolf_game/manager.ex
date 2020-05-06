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
  def handle_call({:get_room, id}, _from, state),
    do: {:reply, get_room(state.table, id), state}

  @impl true
  def handle_call({:create_room, room}, _from, state),
    do: {:reply, create_room(state.table, room), state}

  @impl true
  def handle_call({:update_room, room}, _from, state),
    do: {:reply, update_room(state.table, room), state}

  @impl true
  def handle_call({:delete_room, id}, _from, state),
    do: {:reply, delete_room(state.table, id), state}

  @impl true
  def handle_call({:list_rooms}, _from, state),
    do: {:reply, list_rooms(state.table), state}

  @spec get_room(String.t()) :: {:ok, Room} | {:error, any}
  def get_room(id),
    do: GenServer.call(__MODULE__, {:get_room, id})

  defp get_room(table, id) do
    case :ets.lookup(table, id) do
      [] -> {:error, :no_room_found}
      [room] -> {:ok, deserialize(room)}
    end
  end

  @spec create_room(Room) :: {:ok, Room} | {:error, any}
  def create_room(room),
    do: GenServer.call(__MODULE__, {:create_room, room})

  defp create_room(table, room) do
    room = %Room{room | id: UUID.uuid4(:hex)}
    case :ets.insert_new(table, serialize(room)) do
      true -> {:ok, room}
      false -> {:error, :room_already_exists}
    end
  end

  @spec update_room(Room) :: {:ok, Room} | {:error, any}
  def update_room(room),
    do: GenServer.call(__MODULE__, {:update_room, room})

  defp update_room(table, %Room{id: id} = room) do
    case get_room(table, id) do
      {:ok, _} ->
        :ets.insert(table, serialize(room))
        {:ok, room}

      error ->
        error
    end
  end

  @spec delete_room(String.t()) :: {:ok, Room} | {:error, any}
  def delete_room(id),
    do: GenServer.call(__MODULE__, {:delete_room, id})

  defp delete_room(table, id) do
    case get_room(table, id) do
      {:ok, room} ->
        :ets.delete(table, id)
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
      |> Enum.sort(&(&1.name <= &2.name))
    }
  end

  defp serialize(%Room{id: id, name: name, members: members, owner: owner}) do
    {id, name, members, owner}
  end

  defp deserialize({id, name, members, owner}) do
    %Room{id: id, name: name, members: members, owner: owner}
  end
end
