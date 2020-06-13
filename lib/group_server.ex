defmodule Socialnetwork.GroupServer do
	use GenServer
	alias __MODULE__
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.Person, as: Person

	# Interface ----------------------------------------------------------------
	def start do
		GenServer.start(__MODULE__, nil)
	end

	def add_member(uniquename, name, birthdate, interests) do
		person = Person.new(uniquename, name, birthdate, interests)
		GenServer.cast(GroupServer, {:put, {:add, :member}, person)
	end

	def add_name(group_name) do
		GenServer.cast(GroupServer, {:put, {:add, :name}, group_name})
	end

	def del_member(uniquename) do
		GenServer.cast(GroupServer, {:put, {:delete, :member}})
	end

	def get_member(uniquename) do
		GenServer.call(GroupServer, {:member, uniquename})
	end

	def from_file!(path) do
		GenServer.call(GroupServer, {:from_file, path})
	end

	# Callbacks ----------------------------------------------------------------
	def init(_) do
		{:ok, Group.new()}
	end

	#	def get_member(group = %Group{}, uniquename)
	#	def from_file!(path)
	def handle_call({:get, key}, _, group) do
		response = case key do
			{:member, uniquename} ->
				Group.get_member(group, uniquename)

			{:from_file, path} ->
				Group.from_file!(path)
		end

		{:reply, response, group}
	end

	def handle_cast({:put, key, data}, group) do
		new_group = case key do
			# Keys from the map must be atoms, as only atoms are allowed in struct definition.
			{:add, :member} ->
				Group.add_member(group, data)

			{:add, :name} ->
				Group.add_name(group, data)

			{:delete, :member} ->
				Group.del_member(group, data)

			{:update, :member} ->
				# I think we're still in Atom territory
				# but at some point str to atom will be an issue.
				uniquename = data.uniquename
				field = data.field
				value = data.value
				Group.update_member(group, uniquename, field, value)
		end

		{:noreply, new_group}
	end





#	def new(), do: %Group{}
#	def add_member(group = %Group{}, person = %Socialnetwork.Person{})
#	def add_name(group = %Group{}, name)
#	def del_member(group = %Group{}, uniquename)
#	def update_member(group = %Group{}, uniquename, key, value)

#	def get_member(group = %Group{}, uniquename)
#	def from_file!(path)
end  # End GroupServer.
