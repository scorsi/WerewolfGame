defmodule WerewolfGame.Room do
  defstruct id: "", name: "", members: [], owner: 0, public?: true, status: :open

  alias WerewolfGame.{Room, RoomSupervisor, PublicRoomAgent, RoomRegistry, PubSub}

  use GenServer, restart: :transient

  ### CLIENT API

  def create_room(room) do
    %Room{room | id: UUID.uuid4(:hex)}
    |> RoomSupervisor.start_room()
  end

  def get_info(room_id) do
    GenServer.call(RoomRegistry.get_process_name(room_id), {:get_info})
  end

  def delete_room(room) do
    room
    |> RoomSupervisor.kill_room()
  end

  def subscribe(room) do
    PubSub.subscribe("room:#{room.id}")
    room
  end

  def register_user(room, user) do
    GenServer.call(RoomRegistry.get_process_name(room.id), {:register_user, user})
    PubSub.broadcast("room:#{room.id}", :registered_user, user)
    room
  end

  def unregister_user(room, user) do
    GenServer.call(RoomRegistry.get_process_name(room.id), {:unregister_user, user})
    PubSub.broadcast("room:#{room.id}", :unregistered_user, user)
    room
  end

  def update_room(room) do
    GenServer.call(RoomRegistry.get_process_name(room.id), {:update_room, room})
    PubSub.broadcast("room:#{room.id}", :updated, room)
    room
  end

  ### SERVER API

  @timeout 10 * 1000

  def start_link(opts) do
    {initial_room, opts} = Keyword.pop(opts, :initial_room, %Room{})
    GenServer.start_link(__MODULE__, initial_room, opts)
  end

  @impl true
  def init(state) do
    Process.flag(:trap_exit, true)

    if state.public? do
      PublicRoomAgent.register_room(state)
    end

    {:ok, state, @timeout}
  end

  @impl true
  def terminate(_reason, state) do
    PubSub.broadcast("room:#{state.id}", :terminated)

    if state.public? do
      PublicRoomAgent.unregister_room(state)
    end
  end

  @impl true
  def handle_call({:get_info}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:update_room, room}, _from, state) do
    if state.public? == true and room.public? == false do
      PublicRoomAgent.unregister_room(state)
    else
      if state.public? == false and room.public? == true do
        PublicRoomAgent.register_room(state)
      end
    end

    {:reply, :ok, %{state | name: room.name, public?: room.name, status: room.status},
     {:continue, :end_updated}}
  end

  @impl true
  def handle_call({:register_user, user}, _from, state) do
    {:reply, :ok, %{state | members: state.members ++ [user]},
     {:continue, :end_updated}}
  end

  @impl true
  def handle_call({:unregister_user, user}, _from, state) do
    members = state.members |> Enum.reject(fn u -> u.id == user.id end)

    {:reply, :ok, %{state | members: members}, {:continue, :end_updated}}
  end

  @impl true
  def handle_continue(:end_updated, state) do
    if state.public? do
      PublicRoomAgent.actualize_room(state)
    end

    if length(state.members) == 0 do
      {:noreply, state, @timeout}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end
end
