defmodule WerewolfGame.RoomRegistry do
  def get_process_name(room_id) do
    {:via, Registry, {WerewolfGame.RoomRegistry, room_id}}
  end
end
