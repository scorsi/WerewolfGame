defmodule WerewolfGame.GameCharacter do
  @characters [
    %{
      id: 0,
      name: :werewolf,
      team: :werewolves,
      active: [
        {:night, 1}
      ]
    },
    %{
      id: 1,
      name: :shaman_wolf,
      team: :werewolves,
      active: [
        {:night, 2}
      ]
    },
    %{
      id: 2,
      name: :the_thing,
      team: :villagers,
      active: [
        {:night, 3}
      ]
    },
    %{
      id: 3,
      name: :clairvoyant,
      team: :villagers,
      active: [
        {:night, 4}
      ]
    },
    %{
      id: 4,
      name: :thief,
      team: :villagers,
      active: [
        {:night, 5}
      ]
    },
    %{
      id: 5,
      name: :gremlin,
      team: :villagers,
      active: [
        {:night, 6}
      ]
    },
    %{
      name: :villager,
      team: :villagers,
      active: []
    }
  ]

  def get_all() do
    @characters
  end

  def get_by_name(name) do
    @characters
    |> Enum.find(fn c -> c.name == name end)
  end
end
