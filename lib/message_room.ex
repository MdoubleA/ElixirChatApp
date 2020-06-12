defmodule Socialnetwork.MessageBoard do
	alias __MODULE__
	alias Socialnetwork.Group, as: Group
	defstruct id: nil, messages: [], members: Group.new()

	def new() do
		%MessageBoard{}
	end

	def new(person1, person2) do
		members = Group.add_member(Group.new(), person1) |> Group.add_member(person2)
		%MessageBoard{members: members}
	end

	# Not tested.
	def new(member_list) do
		%MessageBoard{members: member_list}
	end

	def add_message(message_board, username, message) do
		%MessageBoard{message_board| messages: [{username, message} | message_board.messages]}
	end

	def get_sent_messages(message_board, username) do
		Enum.filter(message_board.messages, fn x -> Kernel.elem(x, 0) == username end)
	end

#Tests -------------------------------------------------------------------------

	defp base_tests() do
		path = "C:\\Users\\Michael\\ElixirProjects\\socialnetwork\\lib\\MakePeople.txt"
		person1_name = "Eliot"
		person2_name = "Selena"
		data = Group.from_file!(path)
		person1 = Group.get_member(data, person1_name)
		person2 = Group.get_member(data, person2_name)
		new_message_chain = new(person1, person2)
		IO.inspect(new_message_chain)
		new_message_chain = add_message(new_message_chain, person1_name, "Hello")
							|> add_message(person2_name, "Hi")
							|> add_message(person1_name, "My podcast is awesome. You should listen to it.")
		IO.inspect(new_message_chain)
		IO.inspect(get_sent_messages(new_message_chain, person1_name))
	end

	def run_tests() do
		base_tests()
	end

end # Module end

defmodule MessageServer do
	use GenServer
	alias Socialnetwork.MessageBoard, as: MessageBoard

	# GenServer callbacks.
	#---------------------------------------------------------------------------
	# The parameter to init is the second parameter to GenServer.start(MessageServer, x)
	def init(_), do: {:ok, MessageBoard.new()}

	def handle_cast({:put, key, value}, state) do
		# State is a message board.
		# Value is a message.
		# Key is a sender. Not sure if useing username or person object.
		# Not sure just yet if sent to every member of the group or to a specific member.
		new_messageboard = MessageBoard.add_message(state, key, value)
		{:noreply, new_messageboard}
		# returns {:noreply, new_state}
	end

	def handle_call({:get, key}, _, state) do
		# Key for now is a person, or username.
		# State is a message_board.
		# If you're quering a message board, you want it's members or the messages sent by a particular person.

		response = case key do
					:members -> {:members, state.members}
					username -> {:messages, MessageBoard.get_sent_messages(state, username)}
				  end
		{:reply, response, state}
		# returns {:reply, response, new_state}
	end

	# Server Interfaces.
	#---------------------------------------------------------------------------
	# GenServer.start is a synchronious call and timesout after 5 seconds. A third parameter is in milliseconds to specify timeout.
	def start(), do: GenServer.start(MessageServer, nil)  # returns {:ok, #PID<x.x.x>}
	def put(pid, key, value), do: GenServer.cast(pid, {:put, key, value})
	def get(pid, :members), do: GenServer.call(pid, {:get, :members})
	def get(pid, username), do: GenServer.call(pid, {:get, username})

	# Tests server architecture ------------------------------------------------
	# Testing the interface should implicitly test the callbacks.

	def test_server_interfaces() do
		add_space = fn  -> IO.puts("--------------------") end
		{:ok, server_pid} = start()
		IO.inspect(server_pid)
		add_space.()

		members = get(server_pid, :members)
		IO.inspect(members)

		put(server_pid, "Eliot", "Hello!")
		add_space.()
		messages = get(server_pid, "Eliot")
		IO.inspect(messages)

		put(server_pid, "Selena", "HI!")
		add_space.()
		messages = get(server_pid, "Eliot")
		IO.inspect(messages)

		put(server_pid, "Eliot", "Side note, I'm going COVID crazy.")
		add_space.()
		messages = get(server_pid, "Eliot")
		IO.inspect(messages)
	end


end # Module end
