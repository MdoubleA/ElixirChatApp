defmodule Socialnetwork.TestMessageRoomCache do
	use ExUnit.Case
	alias Socialnetwork.MessageBoardCache, as: Board

	test "Test: Message Board Cache" do
		name1 = "SmartTalk"
		name2 = "NotSmartTalk"

		# Test cache process creation.
		{:ok, cache_pid} = Board.start()
		assert Kernel.is_pid(cache_pid)

		# Test creation of message board as process.
		board_pid1 = Board.get_messageboard(cache_pid, name1)
		assert Kernel.is_pid(board_pid1)

		# Test creation of distinct processes.
		board_pid2 = Board.get_messageboard(cache_pid, name2)
		assert board_pid1 != board_pid2


	end # end test
end # End Test Message Board Cache
