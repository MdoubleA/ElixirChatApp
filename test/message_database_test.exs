defmodule TestMessageDatabase do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageServer, as: Server
	alias Socialnetwork.MessageDatabase, as: Db

	test "MessageDatabase" do
		test_group = Group.from_file!(".\\lib\\SomePeople.txt")
		id = "CoolTalk"
		{:ok, board_pid} = Server.start({id, test_group})
		File.rm(".\\persist\\Messages\\"<>id)

		# Test database creation.
		{:ok, db_pid} = Db.start()
		assert Kernel.is_pid(db_pid)

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

		# IO.inspect(old_board)
		# IO.puts("______________________________________")
		# IO.inspect(Db.get(id))

		Process.exit(Process.whereis(Db), :kill)
	end # End test
end # End TestMessageDatabaseModule
