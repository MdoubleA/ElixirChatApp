defmodule DatabaseTest do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageBoard, as: Board
	alias Socialnetwork.MessageDatabase, as: Db


	test "Database Test" do
		#{:ok, sys_super} = Socialnetwork.MessageBoard.System.start_link()
		id = "CoolTalk"
		File.rm(".\\test\\persist\\Messages\\"<>id)
		test_group = Group.from_file!(".\\lib\\system\\SomePeople.txt")

		# Test initial state of database. No data saved yet.
		mssg_board = Board.new(id)
		assert nil == Db.get(id)
		mssg_board = Board.add_member(mssg_board, "Eliot", test_group)
		Db.store(mssg_board.id, mssg_board)
		assert mssg_board == Db.get(id)

		# Test saving altered database to disk.
		old_board = Db.get(id)
		mssg_board = Board.add_message(mssg_board, "Eliot", "Hello!")
		assert mssg_board != old_board
		Db.store(mssg_board.id, mssg_board)
		Process.sleep(100)
		assert Db.get(id) == mssg_board

		# Give any child process in the system sometime to clean.
		Process.sleep(500)
		#Process.exit(sys_super, :normal)
		#Process.sleep(500)
	end # End test
end # End Database Test
