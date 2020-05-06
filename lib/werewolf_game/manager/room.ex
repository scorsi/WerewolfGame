defmodule WerewolfGame.Manager.Room do
  defstruct id: UUID.uuid4(:hex), name: "", members: [], owner: 0
end
