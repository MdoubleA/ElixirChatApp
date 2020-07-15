defmodule Socialnetwork.UserRepository do
	use GenServer
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.Person, as: Person
	@databasesource "UserRepository"
	# In memory copy of database with additional data manipulation abilites.

	# Interface ----------------------------------------------------------------
	def start(group_name) do
		GenServer.start(__MODULE__, group_name)
	end

	# This will be useful when a final persisting data set is found.
	def start_main_repository() do
		GenServer.start(__MODULE__, @databasesource)
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
				# Frist variable of match is a pattern. So use '^' in front of variable to reference the
				# pattern it references.
				if Kernel.match?(^temp_group, group) do
					group
				else
					Socialnetwork.UserDatabase.store(temp_group.group_name, temp_group)
					temp_group
				end
		end

		{:noreply, new_group}
	end

end  # End UserRepository.
