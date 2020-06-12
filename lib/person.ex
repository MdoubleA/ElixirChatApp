defmodule Socialnetwork.Person do
	alias __MODULE__
	defstruct uniquename: nil, name: nil, birthdate: nil, interests: nil

	# A Person attributes:
	#--------------
	# uniquename        String, can't be changed once given.
	# name              String, can be changed.
	# birthdate         ~D[yyyy-mm-dd], can't be change once given.
	# Interests         [String], Interests.
	:uniquename
	:name
	:birthdate
	:interests


	def new(), do: %Person{}

	# Need to implement nested data structure validation; make sure that interests are valid...should I?
	def new(a_person) do
		%Person{uniquename: a_person.uniquename, name: a_person.name, birthdate: a_person.birthdate, interests: a_person.interests}
	end

	# Not formally tested.
	def new(uniquename, name, birthdate, interests) do
		%Person{uniquename: uniquename, name: name, birthdate: birthdate, interests: interests}
	end

	# Used for fields that can't be changed
	defp update_field(a_person, key, value) do
		Map.update(
		a_person,
		key,
		value,
		fn curr_value -> if curr_value == nil, do: value, else: curr_value end
		)
	end

	# These fields can't be changed once set.
	def add_field(a_person, :uniquename, new_uniquename), do: update_field(a_person, :uniquename, new_uniquename)

	def add_field(a_person, :birthdate, new_birthdate), do: update_field(a_person, :birthdate, new_birthdate)

	# These fields can be changed after set.
	def add_field(a_person, :name, new_name), do: Map.update(a_person, :name, new_name, fn _ -> new_name end)

	def add_field(a_person, :interests, new_interest) do
		Map.update(
		a_person,
		:interests,
		new_interest,
		fn curr_interests -> if curr_interests == nil, do: [new_interest], else: [new_interest | curr_interests] end
		)
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

	def run_tests() do
	  test_results = [true]
	  bob = new()

	  # Test :uniquename management.
	  test_results = [bob.uniquename == nil | test_results]
	  bob = add_field(bob, :uniquename, "Bob")
	  test_results = [bob.uniquename == "Bob" | test_results]
	  bob = add_field(bob, :uniquename, "Michael")
	  test_results = [bob.uniquename == "Bob" | test_results]


	  # Test :name management.
	  test_results = [bob.name == nil | test_results]
	  bob = add_field(bob, :name, "Bob")
	  test_results = [bob.name == "Bob" | test_results]
	  bob = add_field(bob, :name, "Bobby")
	  test_results = [bob.name == "Bobby" | test_results]

	  # Test :birthdate managment.
	  test_results = [bob.birthdate == nil | test_results]
	  bob = add_field(bob, :birthdate, ~D[1977-04-20])
	  test_results = [bob.birthdate == ~D[1977-04-20] | test_results]
	  bob = add_field(bob, :birthdate, ~D[1977-04-19])
	  test_results = [bob.birthdate == ~D[1977-04-20] | test_results]

	  # Test :interests managment.
	  test_results = [bob.interests == nil | test_results]
	  bob = add_field(bob, :interests, "Mike")
	  test_results = [Enum.at(bob.interests, 0) == "Mike" | test_results]
	  bob = add_field(bob, :interests, "Coffee")
	  test_results = [Enum.at(bob.interests, 0) == "Coffee", Enum.at(bob.interests, 1) == "Mike" | test_results]

	  bob2 = new(bob)  # Nested structure validation not in place.
	  test_results = [Map.equal?(bob, bob2) | test_results]
	  test_results = [equal?(bob, bob2) | test_results]

	  to_report = Enum.all?(test_results, &(&1 == true))
	  to_report = if to_report == true, do: {:ok, "Person Module: All systems go."}, else: {:error, "Person Module: Fail."}
	  IO.inspect(to_report)
	  :test_end
	end
end
