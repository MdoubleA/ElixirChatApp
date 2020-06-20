defmodule ServerCacheTest do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageServer, as: Server
	alias Socialnetwork.MessageBoardCache, as: Cache
	alias Socialnetwork.MessageDatabase, as: Db


	# A message board IS a server, but I separeted the board logic and server process
	# logic into distinct modules, in the same file (message_board.ex).
	test "Server Cache Test" do
		id1 = "TedTalk"
		id2 = "BobTalk"
		# Both the following clean up lines are need post integration.
		File.rm(".\\test\\persist\\Messages\\"<>id1)
		File.rm(".\\test\\persist\\Messages\\"<>id2)
		test_group = Group.from_file!(".\\lib\\system\\SomePeople.txt")

		# Test distinct process creation.
		{:ok, sys_super} = Socialnetwork.MessageBoard.System.start_link()
		pid1 = Cache.get_board(id1)
		pid2 = Cache.get_board(id2)
		assert Kernel.is_pid(pid1)
		assert Kernel.is_pid(pid2)

		# Test initial state.
		assert Server.get_board(pid1) == %Socialnetwork.MessageBoard{id: id1,
																			members: %Socialnetwork.Group{group_name: nil,
																			num_people: 0, people: %{}}, messages: []}

		assert Server.get_board(pid2) == %Socialnetwork.MessageBoard{id: id2,
																			members: %Socialnetwork.Group{group_name: nil,
																			num_people: 0, people: %{}}, messages: []}

		# Test data save and retrieve.
		Enum.each(test_group, fn x -> Server.add_member(pid2, Kernel.elem(x, 0), test_group) end)
		Process.sleep(100)  # Give the workers some time to store the data to file.
		assert Db.get(id2) == Server.get_board(pid2)

		# Kill the cache make sure it takes the children with it before it comes back.
		Process.exit(Process.whereis(Cache), :kill)
		Process.sleep(100)  # Wait for clean up.
		assert not Process.alive?(pid1)
		assert not Process.alive?(pid2)
		assert Process.alive?(Process.whereis(Cache))

		# Make sure the children come back with state from file, fi file state exists.
		pid1 = Cache.get_board(id1)
		pid2 = Cache.get_board(id2)
		assert Server.get_board(pid1) == %Socialnetwork.MessageBoard{id: id1,
																			members: %Socialnetwork.Group{group_name: nil,
																			num_people: 0, people: %{}}, messages: []}
		assert Db.get(id2) == Server.get_board(pid2)

		# Kill the children and make sure they don't come back until called.
		Process.exit(pid1, :kill)
		Process.exit(pid2, :kill)
		Process.sleep(100)  # Give the processes some time to clean up.
		assert not Process.alive?(pid1)
		assert not Process.alive?(pid2)

		Process.exit(sys_super, :normal)
		Process.sleep(500)
	end # End test
end # End TestMessageServer
