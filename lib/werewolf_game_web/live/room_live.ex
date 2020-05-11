defmodule WerewolfGameWeb.RoomLive do
  @moduledoc false

  use WerewolfGameWeb.LiveViewPowHelper
  use WerewolfGameWeb, :live_view

  alias Phoenix.View
  alias WerewolfGame.Room
  alias WerewolfGameWeb.RoomView

  @impl true
  def render(%{room: room} = assigns) do
    case room do
      nil ->
        View.render(RoomView, "not_found.html", assigns)

      _ ->
        View.render(RoomView, "index.html", assigns)
    end
  end

  @impl true
  def mount(_, session, socket) do
    socket = maybe_assign_current_user(socket, session)
    {:ok, socket}
  end

  @impl true
  def terminate(
        _reason,
        %{
          assigns: %{
            current_user: current_user,
            room: room
          }
        } = socket
      ) do
    room
    |> Room.unregister_user(current_user)

    socket
  end

  @impl true
  def handle_params(
        %{"id" => id} = _params,
        _uri,
        %{
          assigns: %{
            current_user: current_user
          }
        } = socket
      ) do
    case Room.get_info(id) do
      nil ->
        {:noreply, assign(socket, room: nil)}

      room ->
        Process.send_after(self(), %{event: :join}, 100)

        {
          :noreply,
          assign(
            socket,
            room: room,
            is_owner?: current_user.id == room.owner.id,
            page_title: "Salon #{room.name}"
          )
        }
    end
  end

  @impl true
  def handle_params(
        %{} = _params,
        _uri,
        %{
          assigns: %{
            current_user: current_user
          }
        } = socket
      ) do
    room =
      %Room{name: current_user.nickname, owner: current_user}
      |> Room.create_room()

    {:noreply, redirect(socket, to: Routes.live_path(socket, __MODULE__, id: room.id))}
  end

  @impl true
  def handle_info(
        %{event: :join},
        %{
          assigns: %{
            current_user: current_user,
            room: room
          }
        } = socket
      ) do
    room
    |> Room.subscribe()
    |> Room.register_user(current_user)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %{event: :registered_user, payload: user},
        %{
          assigns: %{
            room: room
          }
        } = socket
      ) do
    {
      :noreply,
      assign(
        socket,
        room: %Room{
          room
          | members: room.members ++ [user]
        }
      )
    }
  end

  @impl true
  def handle_info(
        %{event: :unregistered_user, payload: user},
        %{
          assigns: %{
            room: %Room{members: members} = room
          }
        } = socket
      ) do
    {
      :noreply,
      assign(
        socket,
        room: %Room{
          room
          | members:
              members
              |> Enum.reject(fn u -> u.id == user.id end)
        }
      )
    }
  end

  @impl true
  def handle_info(
        %{event: :new_message, payload: message},
        %{
          assigns: %{
            room:
              %Room{
                messages: messages
              } = room
          }
        } = socket
      ) do
    room = %Room{
      room
      | messages: messages ++ [message]
    }

    {:noreply, assign(socket, room: room)}
  end

  @impl true
  def handle_info(
        %{event: :removed_message, payload: message_id},
        %{
          assigns: %{
            room:
              %Room{
                messages: messages
              } = room
          }
        } = socket
      ) do
    room = %Room{
      room
      | messages:
          messages
          |> Enum.filter(fn m -> m.id != message_id end)
    }

    {:noreply, assign(socket, room: room)}
  end

  @impl true
  def handle_info(
        %{event: :updated, payload: attributes},
        %{
          assigns: %{
            room:
              %Room{
                name: name,
                public?: public?
              } = room
          }
        } = socket
      ) do
    name = Keyword.get(attributes, :name, name)

    public? =
      case Keyword.get(attributes, :public?, public?) do
        "true" -> true
        "false" -> false
        other -> other
      end

    room = %Room{
      room
      | name: name,
        public?: public?
    }

    {:noreply, assign(socket, room: room)}
  end
end
