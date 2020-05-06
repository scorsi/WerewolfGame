defmodule WerewolfGame.ManagerTest do
  use ExUnit.Case

  alias WerewolfGame.Manager
  alias WerewolfGame.Manager.Room

  def manager_start() do
    if GenServer.whereis(Manager) != nil, do: GenServer.stop(Manager, :shutdown)
    Manager.start_link()
  end

  describe "get room" do
    test "ok" do
      manager_start()

      {:ok, room1} = Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1]}} = Manager.get_room(room1.id)

      {:ok, room2} = Manager.create_room(%Room{name: "test2", owner: 2, members: [2, 1]})

      assert {:ok, %Room{name: "test2", owner: 2, members: [2, 1]}} = Manager.get_room(room2.id)
    end

    test "error no room found" do
      manager_start()

      assert {:error, :no_room_found} = Manager.get_room("test")
    end
  end

  describe "create room" do
    test "ok" do
      manager_start()

      assert {:ok, %Room{name: "test1", owner: 1, members: [1]}} =
               Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})

      assert {:ok, %Room{name: "test2", owner: 2, members: [2, 1]}} =
               Manager.create_room(%Room{name: "test2", owner: 2, members: [2, 1]})

      assert {:ok, %Room{name: "test3", members: [3, 1, 2]}} =
               Manager.create_room(%Room{name: "test3", owner: 3, members: [3, 1, 2]})
    end
  end

  describe "delete room" do
    test "ok" do
      manager_start()

      {:ok, room1} = Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})
      {:ok, room2} = Manager.create_room(%Room{name: "test2", owner: 1, members: [1]})
      {:ok, room3} = Manager.create_room(%Room{name: "test3", owner: 1, members: [1]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1]}} = Manager.delete_room(room1.id)
      assert {:ok, %Room{name: "test2", owner: 1, members: [1]}} = Manager.delete_room(room2.id)
      assert {:ok, %Room{name: "test3", owner: 1, members: [1]}} = Manager.delete_room(room3.id)
      assert {:ok, []} = Manager.list_rooms()
    end

    test "error no room found" do
      manager_start()

      assert {:error, :no_room_found} = Manager.delete_room("test")
    end
  end

  describe "list rooms" do
    test "ok" do
      manager_start()

      assert {:ok, []} = Manager.list_rooms()

      {:ok, %Room{id: test1_id}} =
        Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})

      assert {:ok, [%Room{name: "test1", owner: 1, members: [1]}]} = Manager.list_rooms()

      {:ok, %Room{id: test2_id}} =
        Manager.create_room(%Room{name: "test2", owner: 1, members: [1]})

      assert {:ok,
              [
                %Room{name: "test1", owner: 1, members: [1]},
                %Room{name: "test2", owner: 1, members: [1]}
              ]} = Manager.list_rooms()

      {:ok, %Room{id: test3_id}} =
        Manager.create_room(%Room{name: "test3", owner: 1, members: [1]})

      assert {:ok,
              [
                %Room{name: "test1", owner: 1, members: [1]},
                %Room{name: "test2", owner: 1, members: [1]},
                %Room{name: "test3", owner: 1, members: [1]}
              ]} = Manager.list_rooms()

      Manager.delete_room(test2_id)

      assert {:ok,
              [
                %Room{name: "test1", owner: 1, members: [1]},
                %Room{name: "test3", owner: 1, members: [1]}
              ]} = Manager.list_rooms()
    end
  end

  describe "update room" do
    test "ok" do
      manager_start()

      {:ok, %Room{id: test1_id}} =
        Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1, 2]}} =
               Manager.update_room(%Room{id: test1_id, name: "test1", owner: 1, members: [1, 2]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1, 2, 123]}} =
               Manager.update_room(%Room{
                 id: test1_id,
                 name: "test1",
                 owner: 1,
                 members: [1, 2, 123]
               })

      assert {:ok, %Room{name: "test2", owner: 1, members: [1, 123]}} =
               Manager.update_room(%Room{id: test1_id, name: "test2", owner: 1, members: [1, 123]})
    end

    test "error no room found" do
      manager_start()

      assert {:error, :no_room_found} = Manager.update_room(%Room{id: "invalid_id"})
    end
  end
end
