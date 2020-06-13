defmodule TestGroupModule do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.Person, as: Person

	test "Group Module" do
		uniquename = "Eliot"
		name = "Eliot Glazer"
		birthdate = "1983-07-12"
		interest1 = "He has contributed to Funny or Die's BILLY ON THE STREET, Hulu's DIFFICULT PEOPLE and Bravo's ODD MOMS OUT."
		interest2 = "Eliot's video, SHIT NEW YORKERS SAY went viral in January 2012 and has over four million hits on YouTube."
		eliot1 = Person.new(uniquename, name, birthdate, interest1)
		group = Group.new()

		assert Group.new() == %Group{group_name: nil, num_people: 0, people: %{}}
		assert Group.add_member(group, eliot1) == %Group{group_name: nil, num_people: 1, people: %{uniquename => eliot1}}
		group = Group.add_member(group, eliot1)
		assert Group.add_name(group, "TheCrew") == %Group{group_name: "TheCrew", num_people: 1, people: %{uniquename => eliot1}}
		group = Group.update_member(group, uniquename, :interests, interest2)
		assert Group.add_name(group, "TheCrew") == %Group{group_name: "TheCrew", num_people: 1, people:
			%{uniquename =>
			%Person{uniquename: uniquename, name: name, birthdate: ~D[1983-07-12], interests: [interest2, interest1]}}}
		assert Group.get_member(group, uniquename) ==
				%Person{uniquename: uniquename, name: name, birthdate: ~D[1983-07-12], interests: [interest2, interest1]}
		group = Group.add_name(group, "TheCrew")
		assert Group.del_member(group, uniquename) == %Group{group_name: "TheCrew", num_people: 0, people: %{}}
		test_group = Group.from_file!("C:\\Users\\Michael\\ElixirProjects\\socialnetwork\\lib\\SomePeople.txt")
		#IO.inspect(test_group)
		assert Group.to_group(Enum.reverse(test_group), test_group) == test_group
	end
end # End TestGroupModule
