defmodule Socialnetwork.GroupServer do
	use GenServer
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.Person, as: Person

	# Interface ----------------------------------------------------------------
	def start do
		GenServer.start(__MODULE__, nil)
	end

	def add_member(pid, uniquename, name, birthdate, interests) do
		person = Person.new(uniquename, name, birthdate, interests)
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

	def from_file!(pid, path) do
		GenServer.call(pid, {:get, {:from_file, path}})
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

			:self -> group
		end

		{:reply, response, group}
	end

	# Data is polymorphic data since the return is polymorphic.
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
