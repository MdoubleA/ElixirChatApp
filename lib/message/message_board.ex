defmodule Socialnetwork.MessageBoard do
	# Three points of contact, let new functionality = x:
	# 1. Add x to MessageBoard.
	# 2. Add x to MessageServer callbacks.
	# 3. Add x to MessageServer interface.
	alias __MODULE__
	alias Socialnetwork.Group, as: Group

	# Saving members to the database, and all of their metadata is wasteful since
	# we have a user repository. We only need uernames.
	# This change need much refactoring, so waiting to do that till later.
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


# So the message server is connected to the database. So there is a dependency their.
# Welp, I tested the two together so the test needs to be rewritten.
defmodule Socialnetwork.MessageServer do
	alias __MODULE__
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.MessageBoard, as: Board
	alias Socialnetwork.MessageDatabase, as: Db
	use GenServer

	# Call backs, called in the server process. ----------------
	#
	# init/2 is not refactored yet!
	def init({id, %Group{} = group}) do
		#Db.start() Will end up pushing this up the system hierarchy.
		{:ok, Board.new(id, group)}
	 end

	def init(id) do
		# I want the message_board to have to wait on the server.
		# Should not hold up the database cause it uses workers.
		# Db.start()
		# new_board = case Db.get(id) do
		# 	{:ok, board} -> board
		# 	nil -> Board.new(id)
		# end
		# {:ok, new_board}

		#{:ok, Board.new(id)}
		new_board = case Db.get(id) do
			nil -> Board.new(id)
			board -> board
		end

		{:ok, new_board}
	end

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

						# remove_member, returns :ok
						{:remove, username} ->
							Board.remove_member(message_board, username)
					end

		Db.store(new_board.id, new_board)
		{:noreply, new_board}
		# returns {:noreply, new_state}
	end

	def handle_call({:get, key}, _, message_board) do
		response =
			case key do
				:members -> message_board.members
				{:messages, username} -> Board.get_sent_messages(message_board, username)
				:all -> message_board
			end
		{:reply, response, message_board}
	end

	#terminate/2 will need to included at some point for data saving.

	# Server Interfaces, called in client process. ----------------
	#
	# GenServer.start is a synchronious call and timesout after 5 seconds. A third parameter is in milliseconds to specify timeout.
	def start({_id, %Group{}} = x), do: GenServer.start(MessageServer, x)  # returns {:ok, #PID<x.x.x>}
	def start(id), do: GenServer.start(MessageServer, id)

	# Asynchornious calls.
	def add_message(pid, username, message), do: GenServer.cast(pid, {:put, :message, {username, message}})
	def add_member(pid, username, group), do: GenServer.cast(pid, {:put, :member, {username, group}})
	def remove_member(pid, username), do: GenServer.cast(pid, {:put, :remove, username})

	# Synchronious calls.
	def get_members(pid), do: GenServer.call(pid, {:get, :members})
	def get_messages(pid, username), do: GenServer.call(pid, {:get, {:messages, username}})
	def get_board(pid), do: GenServer.call(pid, {:get, :all})
end  # End MessageServer
