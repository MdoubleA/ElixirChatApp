defmodule Socialnetwork.UserRepository do
	use GenServer
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.Person, as: Person #  Our goal is to not need this here.
	#alias Socialnetwork.UserDatabase, as: Db
	# This calls UserDatabase, and UserDatabase stores data to file.
	# I guess here we have a critical decision.
	# 1. Either keep a copy of all users in memory and pass updates (writes) to database.
	# 2. Or have all reads and writes go through the database, conducting numerous IO operations.
	# I'll never have too large of a set of users.
	# Doing 2. If change use a copy of group server to hold an in memory copy and
	# perform db IO only on write. Will probably just use some 3rd party someting anyway.
	# Here's another issue: Do I store the whole group in one file or
	# One group, one file . . . on each and every read :(

	# So this is a group server but with write to db capacity.
	# So this is like out managment class that would, for example, see if a user exists, and if it does,
	# Defere to some messaging component to handle that piece.

	# This will span worker processes for reads, and
	# pass writes to data base that will spawn work processes for the writes


	# Interface ----------------------------------------------------------------
	def start(group_name) do
		GenServer.start(__MODULE__, group_name)
	end

	def add_member(pid, uniquename, name, birthdate, interests) do
		person = Person.new(uniquename, name, birthdate, interests)
		GenServer.cast(pid, {:put, {:add, :member}, person})
	end

	def add_member(pid, %Person{} = person) do
		GenServer.cast(pid, {:put, {:add, :member}, person})
	end

	def add_name(pid, group_name) do
		GenServer.cast(pid, {:put, {:add, :name}, group_name})
	end

	def del_member(pid, uniquename) do
		GenServer.cast(pid, {:put, {:delete, :member}, uniquename})
	end

	def get_member(pid, uniquename) do
		GenServer.call(pid, {:get, {:member, uniquename}})
	end

	def get_group(pid) do
		GenServer.call(pid, {:get, :self})
	end

	# Callbacks ----------------------------------------------------------------
	def init(group_name) do
		Socialnetwork.UserDatabase.start()
		# This blocks the caller untill all the data has been loaded from disk.
		# For not, this is okay. And be okay always if the number of totall users is small.
		group = Socialnetwork.UserDatabase.get(group_name) || Group.add_name(Group.new(), group_name)
		{:ok, group}
	end

	#	def get_member(group = %Group{}, uniquename)
	#	def from_file!(path)
	def handle_call({:get, key}, _, group) do
		response = case key do
			{:member, uniquename} ->
				Group.get_member(group, uniquename)

			{:from_file, path} ->
				Group.from_file!(path)

			:self -> group
		end

		{:reply, response, group}
	end

	# Data is polymorphic data since the return is polymorphic.
	def handle_cast({:put, key, data}, group) do
		new_group = case key do
			# Keys from the map must be atoms, as only atoms are allowed in struct definition.
			{:add, :member} ->
				temp_group = Group.add_member(group, data)
				if temp_group.num_people > group.num_people do
					Socialnetwork.UserDatabase.store(temp_group.group_name, temp_group)
					temp_group
				else
					group
				end

			{:add, :name} ->
				# If you change the data after initialization, data is saved to new file.
				Group.add_name(group, data)

			{:delete, :member} ->
				temp_group = Group.del_member(group, data)
				if temp_group.num_people < group.num_people do
					Socialnetwork.UserDatabase.store(temp_group.group_name, temp_group)
					temp_group
				else
					group
				end

			{:update, :member} ->
				# I think we're still in Atom territory
				# but at some point str to atom will be an issue.
				uniquename = data.uniquename
				field = data.field
				value = data.value
				temp_group = Group.update_member(group, uniquename, field, value)
				if Kernel.match?(temp_group, group) do
					group
				else
					Socialnetwork.UserDatabase.store(temp_group.group_name, temp_group)
				end
		end

		{:noreply, new_group}
	end

end  # End UserRepository.
