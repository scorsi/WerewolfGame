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

      Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})
      assert {:ok, %Room{name: "test1", owner: 1, members: [1]}} = Manager.get_room("test1")
      Manager.create_room(%Room{name: "test2", owner: 2, members: [2, 1]})
      assert {:ok, %Room{name: "test2", owner: 2, members: [2, 1]}} = Manager.get_room("test2")
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

    test "error room already exists" do
      manager_start()

      Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})
      Manager.create_room(%Room{name: "test2", owner: 2, members: [2]})
      assert {:error, :room_already_exists} = Manager.create_room(%Room{name: "test1"})
      assert {:error, :room_already_exists} = Manager.create_room(%Room{name: "test2"})
    end
  end

  describe "delete room" do
    test "ok" do
      manager_start()

      Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})
      Manager.create_room(%Room{name: "test2", owner: 1, members: [1]})
      Manager.create_room(%Room{name: "test3", owner: 1, members: [1]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1]}} = Manager.delete_room("test1")

      assert {:ok,
              [
                %Room{name: "test2", owner: 1, members: [1]},
                %Room{name: "test3", owner: 1, members: [1]}
              ]} = Manager.list_rooms()

      assert {:ok, %Room{name: "test3", owner: 1, members: [1]}} = Manager.delete_room("test3")
      assert {:ok, [%Room{name: "test2", owner: 1, members: [1]}]} = Manager.list_rooms()
      assert {:ok, %Room{name: "test2", owner: 1, members: [1]}} = Manager.delete_room("test2")
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
      Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})
      assert {:ok, [%Room{name: "test1", owner: 1, members: [1]}]} = Manager.list_rooms()
      Manager.create_room(%Room{name: "test2", owner: 1, members: [1]})

      assert {:ok,
              [
                %Room{name: "test1", owner: 1, members: [1]},
                %Room{name: "test2", owner: 1, members: [1]}
              ]} = Manager.list_rooms()

      Manager.create_room(%Room{name: "test3", owner: 1, members: [1]})

      assert {:ok,
              [
                %Room{name: "test1", owner: 1, members: [1]},
                %Room{name: "test2", owner: 1, members: [1]},
                %Room{name: "test3", owner: 1, members: [1]}
              ]} = Manager.list_rooms()

      Manager.delete_room("test2")

      assert {:ok,
              [
                %Room{name: "test1", owner: 1, members: [1]},
                %Room{name: "test3", owner: 1, members: [1]}
              ]} = Manager.list_rooms()
    end
  end

  describe "update room" do
    test "update values" do
      manager_start()

      Manager.create_room(%Room{name: "test1", owner: 1, members: [1]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1, 2]}} =
               Manager.update_room("test1", %Room{name: "test1", owner: 1, members: [1, 2]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1, 2, 123]}} =
               Manager.update_room("test1", %Room{name: "test1", owner: 1, members: [1, 2, 123]})

      assert {:ok, %Room{name: "test1", owner: 1, members: [1, 123]}} =
               Manager.update_room("test1", %Room{name: "test1", owner: 1, members: [1, 123]})
    end

    test "update name" do
      manager_start()

      Manager.create_room(%Room{name: "test1", owner: 1, members: [1, 2]})

      assert {:ok, %Room{name: "test2", owner: 1, members: [1, 2]}} =
               Manager.update_room("test1", %Room{name: "test2", owner: 1, members: [1, 2]})

      assert {:error, :no_room_found} = Manager.get_room("test1")
      assert {:ok, %Room{name: "test2", owner: 1, members: [1, 2]}} = Manager.get_room("test2")
    end

    test "error no room found" do
      manager_start()

      assert {:error, :no_room_found} = Manager.update_room("test", %Room{})
    end
  end
end
