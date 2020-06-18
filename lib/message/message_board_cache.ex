defmodule Socialnetwork.MessageBoardCache do
	use GenServer
	alias Socialnetwork.MessageServer, as: MessageServer
	# The cash will have a manager of some sort to handle Mapping user names to
	# unique ids. This is just a mapping of unique ids to pid's. If the system were
	# to get big, this process is used to synchronize unique key managment.

	# Call backs, called in cache process --------
	def init(_) do
		# state, %{} is the message_boards.
		{:ok, %{}}
	end

	def handle_call({:get, board_name}, _, message_boards) do
		{board_pid, new_boards} = case Map.fetch(message_boards, board_name) do

			# Get the pid associated with board_name
			{:ok, pid} -> {pid, message_boards}

			# If no association, make one.
			:error ->
				{:ok, pid} = MessageServer.start(board_name)
				new_state = Map.put(message_boards, board_name, pid)
				{pid, new_state}
			end

		{:reply, board_pid, new_boards}
	end

	# Interface functions, Called in cliet process -------------
	def start_link(_) do
		#IO.inspect(self())
		#IO.puts("Starting Message Cache.")
		GenServer.start_link(__MODULE__, nil, name: __MODULE__)
	end

	def get_messageboard(board_name) do
		GenServer.call(__MODULE__, {:get, board_name})
	end

end  # End Message Board Cache
