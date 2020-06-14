defmodule Socialnetwork.MessageBoard do
	# Three points of contact, let new functionality = x:
	# 1. Add x to MessageBoard.
	# 2. Add x to MessageServer callbacks.
	# 3. Add x to MessageServer interface.
	alias __MODULE__
	alias Socialnetwork.Group, as: Group
	defstruct id: nil, messages: [], members: Group.new()

	# Basic data manipulations.
	# Create -------------------------------------------------------------------
	# Assuming message board is created after people with messages are gathered.
	def new(id, %Group{} = group) do
		%MessageBoard{id: id, members: group}
	end

	def new(id), do: %MessageBoard{id: id}  # Not formally tested.

	# Read ---------------------------------------------------------------------
	def get_sent_messages(message_board, username) do
		Enum.filter(message_board.messages, fn x -> Kernel.elem(x, 0) == username end)
	end

	# Update -------------------------------------------------------------------
	def add_message(message_board, username, message) do
		%MessageBoard{message_board| messages: [{username, message} | message_board.messages]}
	end

	def add_member(message_board, username, group) do
		new_person = Group.get_member(group, username)
		new_group = Group.add_member(message_board.members, new_person)
		%MessageBoard{message_board| members: new_group}
	end

	# Delete -------------------------------------------------------------------
	def remove_member(message_board, username) do
		new_members = Group.del_member(message_board.members, username)
		new_messages = Enum.filter(message_board.messages, fn x -> Kernel.elem(x, 0) != username end)
		%MessageBoard{message_board| messages: new_messages, members: new_members}
	end
end # End MessageBoard


defmodule Socialnetwork.MessageServer do
	alias __MODULE__
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageBoard, as: Board
	use GenServer

	# GenServer callbacks.
	#---------------------------------------------------------------------------
	# The parameter to init is the second parameter to GenServer.start(MessageServer, x)
	def init({id, %Group{} = group}), do: {:ok, Board.new(id, group)}
	def init({id}), do: {:ok, Board.new(id)}

	def handle_cast({:put, key, value}, message_board) do
		new_board = case {key, value} do
						# Add a message.
						# new_message = {username, message}
						{:message, {username, message}} ->
							Board.add_message(message_board, username, message)

						# Add a member.
						# I want MessageBoard to be dependent on username and Group module to access data.
						{:member, {username, group}} ->
							Board.add_member(message_board, username, group)

						# remove_member
						{:remove, username} ->
							Board.remove_member(message_board, username)
					end
		{:noreply, new_board}
		# returns {:noreply, new_state}
	end

	def handle_call({:get, key}, _, message_board) do
		response =
			case key do
				:members -> {:members, message_board.members}
				{:messages, username} -> {:messages, Board.get_sent_messages(message_board, username)}
			end
		{:reply, response, message_board}
	end

	#terminate/2 will need to included at some point for data saving.

	# Server Interfaces.
	#---------------------------------------------------------------------------
	# GenServer.start is a synchronious call and timesout after 5 seconds. A third parameter is in milliseconds to specify timeout.
	def start({_id, %Group{}} = x), do: GenServer.start(MessageServer, x)  # returns {:ok, #PID<x.x.x>}
	def start({_id} = x), do: GenServer.start(MessageServer, x)

	# Asynchornious calls.
	def add_message(pid, username, message), do: GenServer.cast(pid, {:put, :message, {username, message}})
	def add_member(pid, username, group), do: GenServer.cast(pid, {:put, :member, {username, group}})
	def remove_member(pid, username), do: GenServer.cast(pid, {:put, :remove, username})

	# Synchronious calls.
	def get_members(pid), do: GenServer.call(pid, {:get, :members})
	def get_messages(pid, username), do: GenServer.call(pid, {:get, {:messages, username}})
end  # End MessageServer


# Test MessageServer the interface to MessageBoard.
defmodule TestMessageServer do
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageServer, as: Server

	defp test_creation() do
		some_users = Group.from_file!(".\\lib\\SomePeople.txt")
		Server.start({0, some_users})
	end

	defp test_get_member(server_pid) do
		board = Server.get_members(server_pid)
		IO.inspect(board)
		IO.puts("---------------------------------------------\n")
		{:ok, 1}
	end

	defp test_get_messages(server_pid) do
		messages = Server.get_messages(server_pid, "Eliot")
		IO.inspect(messages)
		IO.puts("---------------------------------------------\n")
		{:ok, 1}
	end

	defp test_add_message(server_pid) do
		Server.add_message(server_pid, "Eliot", "Hello! I'm Eliot Glazer.")
		messages = Server.get_messages(server_pid, "Eliot")
		IO.inspect(messages)
		IO.puts("---------------------------------------------\n")
		{:ok, 1}
	end

	defp test_add_member(server_pid) do
		all_users = Group.from_file!(".\\lib\\MakePeople.txt")

		Server.add_member(server_pid, "Elon", all_users)
		Server.add_message(server_pid, "Elon", "Nice to meet you! I'm Elon.")
		members = Server.get_members(server_pid)
		IO.inspect(members)
		IO.puts("---------------------------------------------\n")
		{:ok, 1}
	end

	defp test_remove_member(server_pid) do
		Server.remove_member(server_pid, "Eliot")
		members = Server.get_members(server_pid)
		messages = Server.get_messages(server_pid, "Eliot")
		IO.inspect(members)
		IO.inspect(messages)
		messages = Server.get_messages(server_pid, "Elon")
		IO.inspect(messages)
		IO.puts("---------------------------------------------\n")
		{:ok, 1}
	end

	def run_tests() do
		with {:ok, server_pid} <- test_creation(),
		     {:ok, _} <- test_get_member(server_pid),
			 {:ok, _} <- test_get_messages(server_pid),
			 {:ok, _} <- test_add_message(server_pid),
			 {:ok, _} <- test_add_member(server_pid),
			 {:ok, _} <- test_remove_member(server_pid) do
		  IO.inspect({:ok, "Message Server: All systems go."})
		  :test_end
		end
	end


end  # End TestMessageServer
