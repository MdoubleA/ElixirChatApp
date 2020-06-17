defmodule Socialnetwork.Person do
	alias __MODULE__
	defstruct uniquename: nil, name: nil, birthdate: nil, interests: []
	# A Person attributes:
	#--------------
	# uniquename        String, can't be changed once given.
	# name              String, can be changed.
	# birthdate         ~D[yyyy-mm-dd], can't be change once given.
	# Interests         [String], Interests.

	def new(), do: %Person{}

	def new(uniquename, name, birthdate, interests) do
		Person.add_field(new(), :uniquename, uniquename)
		|> Person.add_field(:name, name)
		|> Person.add_field(:birthdate, birthdate)
		|> Person.add_field(:interests, interests)
	end

	def clone(%Person{} = person) do
		%Person{uniquename: person.uniquename, name: person.name, birthdate: person.birthdate, interests: person.interests}
	end

	# not tesed yet.
	# not used yet but may be needed.
	def raw_to_person(data) do
		person = Enum.each(data, fn x ->
			key = Kernel.elem(x, 0) |> String.to_existing_atom()
			value = Kernel.elem(x, 1)
			{key, value}
		end)
		new(person.uniquename, person.name, person.birthdate, person.interests)
	end

	defp to_date(date) do
		[year, month, day] = String.split(date, "-")
		case Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day)) do
		  {:ok, new_date} -> new_date
		  {:error, _} -> nil
		end
	end

	def add_field(person, key, value) do
		case key do
			:name -> Map.update(person, :name, value, fn _ -> value end)
			:birthdate -> Map.update(
				person,
				:birthdate,
				value,
				fn curr_date -> if curr_date == nil, do: to_date(value), else: curr_date end
				)
			:uniquename -> Map.update(
				person,
				:uniquename,
				value,
				fn curr_name -> if curr_name == nil, do: value, else: curr_name end
				)

			:interests -> Map.update(
					person,
					:interests,
					value,
					fn curr_interests -> List.flatten([value | curr_interests], []) end
					)
		end
	end

	# Determines if two person instnaces have same data; they could reference different memory.
	def equal?(person1, person2) do
		Map.equal?(person1, person2)
	end

	defimpl String.Chars, for: Person do
		def to_string(a_person) do
			name = unless a_person.uniquename == nil, do: a_person.uniquename, else: "nil"
			"#Person<uniquename: #{name}>"
		end
	end
end  # End Socialnetwork.Person Module
