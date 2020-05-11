defmodule WerewolfGame.PublicRoom do
  @moduledoc false

  defstruct id: "", name: "", member_count: 0, status: :open

  alias WerewolfGame.PublicRoom

  def create_from_room(room) do
    %PublicRoom{
      id: room.id,
      name: room.name,
      member_count: length(room.members),
      status: room.status
    }
  end
end
