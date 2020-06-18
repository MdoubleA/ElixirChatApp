defmodule DatabaseBoardServerIntegrationTest do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageServer, as: Server
	alias Socialnetwork.MessageDatabase, as: Db

	test "Database Board Server Integration" do
		{:ok, sys_super} = Socialnetwork.MessageBoard.System.start_link()
		id = "CoolTalk"
		test_group = Group.from_file!(".\\lib\\SomePeople.txt")
		{:ok, board_pid} = Server.start({id, test_group})
		File.rm(".\\persist\\Messages\\"<>id)

		# Test initial state of database. No data saved yet.
		assert nil == Db.get(id)

		# Test saving data to database.
		:ok = Db.store(id, Server.get_board(board_pid))
		assert Db.get(id) == Server.get_board(board_pid)

		# Test saving altered database to disk.
		old_board = Db.get(id)
		:ok = Server.add_message(board_pid, "Eliot", "Hello!")
		:ok = Db.store(id, Server.get_board(board_pid))
		assert Db.get(id) != old_board
		#
		# # IO.inspect(old_board)
		# # IO.puts("______________________________________")
		# # IO.inspect(Db.get(id))
		#
		# Process.exit(Process.whereis(Db), :kill)
		# This clean up is need post integration.
		Process.exit(sys_super, :normal)
		Process.sleep(500)
	end # End test

	# defp get_board_pid(key) do
	# 	:erlang.phash2(key, @pool_size) + 1 # +1 since not zero-indexing.
	# end

end # End TestMessageDatabaseModule
