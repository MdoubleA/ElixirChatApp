defmodule Socialnetwork.MessageBoardCache do
	use GenServer
	alias Socialnetwork.MessageServer, as: MessageServer
	# The cash will have a manager of some sort

	# Call backs ---------------------------------------------------------------
	def init(_) do
		# state, %{} is the message_boards
		{:ok, %{}}
	end

	def handle_call({:get, board_name}, _, message_boards) do
		{board_pid, new_boards} = case Map.fetch(message_boards, board_name) do
			# Get the pid associated with board_name
			{:ok, pid} -> {pid, message_boards}

			# If no association, make one.
			:error ->
				{:ok, pid} = Socialnetwork.MessageServer.start(board_name)
				new_state = Map.put(message_boards, board_name, pid)
				{pid, new_state}
		end
		{:reply, board_pid, new_boards}
	end

	# Interface functions ------------------------------------------------------
	def start do
		GenServer.start(__MODULE__, nil)
	end

	def get_messageboard(cache_pid, board_name) do
		GenServer.call(cache_pid, {:get, board_name})
	end
end
