defmodule Socialnetwork.Group do
	alias __MODULE__
	alias Socialnetwork.Person, as: Person
	defstruct group_name: nil, num_people: 0, people: %{}

	def new(), do: %Group{}

	def add_member(group = %Group{}, person = %Socialnetwork.Person{}) do
		case Map.has_key?(group.people, person.uniquename) do
			true -> group
			false -> %Group{group | num_people: group.num_people + 1, people: Map.put(group.people, person.uniquename, person)}
		end
	end

	def add_name(group = %Group{}, name) do
		%Group{group | group_name: name}
	end

	def update_member(group = %Group{}, uniquename, key, value) do
		case Map.fetch(group.people, uniquename) do
			{:ok, orig_person} ->
				new_person = Person.add_field(orig_person, key, value)
				%Group{group | people: Map.put(group.people, new_person.uniquename, new_person)}

			:error -> group
		end
	end

	def get_member(group = %Group{}, uniquename) do
		case Map.fetch(group.people, uniquename) do
			{:ok, the_person} -> the_person
			:error -> {:error, uniquename}
		end
	end

	def del_member(group = %Group{}, uniquename) do
		if Map.has_key?(group.people, uniquename) do
			new_people = Map.delete(group.people, uniquename)
			%Group{group | num_people: group.num_people - 1, people: new_people}
		else
			group
		end
	end

	def from_file!(path) do
		fields_ls_to_person = fn [uniquename, name, birthdate, interest1, interest2, interest3] ->
			Socialnetwork.Person.new(uniquename, name, birthdate, interest1)
			|> Socialnetwork.Person.add_field(:interests, interest2)
			|> Socialnetwork.Person.add_field(:interests, interest3)
		end
		File.stream!(path)
		|> Stream.map(&String.replace(&1,"\n", ""))
		|> Stream.map(&String.split(&1, "\t"))  # Tabs and platform...get's tricky.
		|> Enum.map(&(fields_ls_to_person.(&1)))
		|> Enum.reduce(Group.new(), fn person, group -> add_member(group, person) end)
	end

	# Convert a [{uniquename, Person}] into a group
	# A lot of Enum functions return lists, but we want the abstraction of a group.
	def to_group(list, group) do
		new_people = Enum.into(list, %{})
		%Group{group| people: new_people}
	end

	# Tested visually during development.
	defimpl Enumerable, for: Group do
		def reduce(_group, {:halt, acc}, _fun), do: {:halted, acc}
		def reduce(group, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(group, &1, fun)}
		def reduce(%Group{group_name: _, num_people: 0, people: %{}}, {:cont, acc}, _fun), do: {:done, acc}
		def reduce(%Group{group_name: _, num_people: count, people: the_people} = g, {:cont, acc}, fun) do
			# First make a new group without a given key,value. Don't forget to decrement counter.
			# Apply function to removed key,value.
			# Pass both to a call to reduce.
			people_ls = Map.to_list(the_people)
			head = hd(people_ls)
			tail = tl(people_ls)
			new_count = count - 1
			new_group = %Group{g | num_people: new_count, people: Enum.into(tail, %{})}
			reduce(new_group, fun.(head, acc), fun)
		end

		def count(%Group{} = g), do: {:ok, Enum.reduce(g, 0, fn _, acc -> acc + 1 end)}
		def slice(%Group{} = g) do
		  slicer =  fn start, length ->
				    ls_group = Map.to_list(g.people)
				    Enum.slice(ls_group, start, length)
		  			end
		  {:ok, slicer}
		end
		def member?(%Group{} = g, %Socialnetwork.Person{} = p), do: {:ok, Map.has_key?(g.people, p.uniquename)}
	end

end  # End Group Module
