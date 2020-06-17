defmodule TestMessageServer do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageServer, as: Server
	alias Socialnetwork.MessageDatabase, as: Db


	# A message board IS a server, but I separeted the board logic and server process
	# logic into distinct modules, in the same file (message_board.ex).
	test "Message Server and Message Board" do
		id1 = "TedTalk"
		id2 = "BobTalk"
		test_group = Group.from_file!(".\\lib\\SomePeople.txt")

		# Test distinct process creation.
		{:ok, pid1} = Server.start(id1)
		{:ok, pid2} = Server.start({id2, test_group})
		assert Kernel.is_pid(pid1)
		assert Kernel.is_pid(pid2)
		assert pid1 != pid2

		# Test initial state.
		empty_group = Server.get_members(pid1)
		assert empty_group.num_people == 0
		full_group = Server.get_members(pid2)
		assert full_group == test_group

		# Test state manipulation.
		# Remove member.
		Server.remove_member(pid2, "Eliot")
		assert {:error, "Eliot"} == Server.get_members(pid2) |> Group.get_member("Eliot")

		# Add member.
		Server.add_member(pid1, "Eliot", test_group)
		assert 1 == Server.get_members(pid1).num_people
		assert Group.get_member(test_group, "Eliot") ==
			Server.get_members(pid1) |> Group.get_member("Eliot")

		# Test message handling.
		# Messages are only removed when the sending user is removed.
		assert [] == Server.get_messages(pid1, "Eliot")
		Server.add_message(pid1, "Eliot", "Hello!")
		assert [{"Eliot", "Hello!"}] == Server.get_messages(pid1, "Eliot")

		Server.remove_member(pid1, "Eliot")
		assert [] == Server.get_messages(pid1, "Eliot")

		Process.exit(Process.whereis(Db), :kill)
	end # End test
end # End TestMessageServer
