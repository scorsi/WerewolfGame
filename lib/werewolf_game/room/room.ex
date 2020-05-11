defmodule WerewolfGame.Room do
  defstruct id: "",
            name: "",
            members: [],
            owner: 0,
            public?: false,
            status: :open,
            messages: [],
            required_players: 0,
            selected_characters: [],
            assigned_characters: [],
            characters_left: [],
            actual_character: nil,
            actual_phase: :first_day

  alias WerewolfGame.{RoomSupervisor, Auth.User, Room, PubSub, PublicRoomAgent}

  use GenServer, restart: :transient

  ### CLIENT API

  def subscribe(%Room{} = room) do
    PubSub.subscribe("room:#{room.id}")
    room
  end

  def post_message(room, message, user),
      do: RoomSupervisor.cast_process(room, {:post_message, message, user})

  def get_info(room),
      do: RoomSupervisor.call_process(room, {:get_info})

  def create_room(room),
      do: RoomSupervisor.start_room(%Room{room | id: UUID.uuid4(:hex)})

  def delete_room(room),
      do: RoomSupervisor.kill_room(room)

  def register_user(room, user),
      do: RoomSupervisor.cast_process(room, {:register_user, user})

  def unregister_user(room, user),
      do: RoomSupervisor.cast_process(room, {:unregister_user, user})

  def update_room(room, attributes),
      do: RoomSupervisor.cast_process(room, {:update_room, attributes})

  def start_game(room),
      do: RoomSupervisor.cast_process(room, {:start_game})

  ### SERVER API

  @room_timeout 30_000
  @message_timeout 30_000

  def start_link(opts) do
    {initial_state, opts} = Keyword.pop(opts, :initial_state, %Room{})
    GenServer.start_link(Room, initial_state, opts)
  end

  @impl true
  def init(%Room{} = state) do
    Process.flag(:trap_exit, true)

    if state.public? do
      PublicRoomAgent.register_room(state)
    end

    {:ok, state, @room_timeout}
  end

  @impl true
  def terminate(_reason, %Room{} = state) do
    PubSub.broadcast("room:#{state.id}", :terminated)

    if state.public? do
      PublicRoomAgent.unregister_room(state)
    end

    state
  end

  @impl true
  def handle_call({:get_info}, _from, %Room{} = state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:update_room, attributes}, %Room{name: name, public?: public?} = state) do
    name = Keyword.get(attributes, :name, name)
    public? =
      case Keyword.get(attributes, :public?, public?) do
        "true" -> true
        "false" -> false
        other -> other
      end

    state = %Room{
      state |
      name: name,
      public?: public?
    }

    case public? do
      true -> PublicRoomAgent.register_room(state)
      false -> PublicRoomAgent.unregister_room(state)
    end

    PubSub.broadcast("room:#{state.id}", :updated, attributes)

    {:noreply, state, {:continue, :end_update}}
  end

  @impl true
  def handle_cast({:register_user, %User{} = user}, %Room{} = state) do
    user = %{nickname: user.nickname, id: user.id}

    state = %Room{
      state |
      members: state.members ++ [user]
    }

    PubSub.broadcast("room:#{state.id}", :registered_user, user)

    {:noreply, state, {:continue, :end_update}}
  end

  @impl true
  def handle_cast({:unregister_user, %User{} = user}, %Room{} = state) do
    state = %Room{
      state |
      members:
        state.members
        |> Enum.reject(fn u -> u.id == user.id end)
    }

    PubSub.broadcast("room:#{state.id}", :unregistered_user, user)

    {:noreply, state, {:continue, :end_update}}
  end

  @impl true
  def handle_cast(
        {
          :post_message,
          message,
          %User{} = user
        },
        %Room{
          messages: messages
        } = state
      ) do
    message = %{
      id: UUID.uuid4(),
      text: message,
      user: user.nickname
    }
    state = %Room{
      state |
      messages: messages ++ [message]
    }

    PubSub.broadcast("room:#{state.id}", :new_message, message)

    Process.send_after(self(), {:clear_message, message.id}, @message_timeout)

    {:noreply, state}
  end

  @impl true
  def handle_continue(:end_update, %Room{} = state) do
    if state.public? do
      PublicRoomAgent.actualize_room(state)
    end

    if Enum.empty?(state.members) do
      {:noreply, state, @room_timeout}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_info({:clear_message, message_id}, %Room{messages: messages} = state) do
    state = %Room{
      state |
      messages:
        messages
        |> Enum.filter(fn m -> m.id != message_id end)
    }

    PubSub.broadcast("room:#{state.id}", :removed_message, message_id)

    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, %Room{} = state) do
    {:stop, :normal, state}
  end
end
