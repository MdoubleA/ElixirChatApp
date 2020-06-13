defmodule Socialnetwork.Cache do
	use GenServer

	def init(_) do
		{:ok, %{}}
	end

	def handle_call({:server_process, messageboard_name}, _, message_boards) do
		case Map.fetch(message_boards, messageboard_name) do
			{:ok, board} ->
				{:reply, board, message_boards}
			:error ->
				{:ok, new_board} = Socialnetwork.MessageServer.start(messageboard_name)  # Might change for numerical id.
				{:reply, new_board, Map.put(message_boards, messageboard_name, new_board)}
		end
	end

	def start do
		GenServer.start(__MODULE__, nil)
	end

	def server_process(cache_pid, messageboard_name) do
		GenServer.call(cache_pid, {:server_process, messageboard_name})
	end
end
