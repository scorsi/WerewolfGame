defmodule WerewolfGame.GameScenario do
  @scenarios [
    %{
      name: :first_night,
      configurations: [
        %{
          players: 3,
          characters: [
            {:werewolf, 1},
            {:shaman_wolf, 1},
            {:clairvoyant, 1},
            {:thief, 1},
            {:gremlin, 1},
            {:villager, 1}
          ]
        },
        %{
          players: 4,
          characters: [
            {:werewolf, 1},
            {:shaman_wolf, 1},
            {:clairvoyant, 1},
            {:thief, 1},
            {:gremlin, 1},
            {:villager, 2}
          ]
        },
        %{
          players: 5,
          characters: [
            {:werewolf, 1},
            {:shaman_wolf, 1},
            {:clairvoyant, 1},
            {:thief, 1},
            {:gremlin, 1},
            {:villager, 2},
            {:the_thing, 1}
          ]
        }
      ]
    }
  ]

  def get_all() do
    @scenarios
  end

  def get_by_name(name) do
    get_all()
    |> Enum.find(&(&1.name == name))
  end

  def get_by_name_and_players(name, players) do
    get_by_name(name)
    |> Map.get(:configurations)
    |> Enum.find(&(&1.players == players))
    |> Map.get(:characters)
  end
end
