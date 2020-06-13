defmodule TestGroupServer do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.Person, as: Person
	alias Socialnetwork.GroupServer, as: Server

	test "Test: GroupServer" do
		groupname = "TheCrew"

		# Test initialization creates properly formatted "blank slate."
		{:ok, server_pid} = Server.start()
		assert %Group{group_name: nil, num_people: 0, people: %{}}
			== Server.get_group(server_pid)

		# Test name change and name persistance.
		assert :ok == Server.add_name(server_pid, groupname)
		assert %Group{group_name: groupname, num_people: 0, people: %{}}
			== Server.get_group(server_pid)

		# Test Person additiont and persistance.
		uniquename = "Eliot"
		name = "Eliot Glazer"
		birthdate = "1983-07-12"
		interest1 = "He has contributed to Funny or Die's BILLY ON THE STREET," <>
			" Hulu's DIFFICULT PEOPLE and Bravo's ODD MOMS OUT."
		interest2 = "Eliot's video, SHIT NEW YORKERS SAY went viral in January " <>
			"2012 and has over four million hits on YouTube."
		eliot = Person.new(uniquename, name, birthdate, [interest1, interest2])
		eliot2 = %Person{eliot| uniquename: "Eliot2"}

		# Add eliot.
		assert :ok == Server.add_member(server_pid, uniquename, name, birthdate,
			[interest1, interest2])
		assert %Group{group_name: groupname, num_people: 1, people:
			%{uniquename => eliot}} == Server.get_group(server_pid)

		# Add eliot2.
		assert :ok == Server.add_member(server_pid, "Eliot2", name, birthdate,
			[interest1, interest2])
		assert %Group{group_name: groupname, num_people: 2, people:
			%{uniquename => eliot, "Eliot2" => eliot2}} == Server.get_group(server_pid)

		# Test delete function by deleteing Eliot2.
		assert :ok == Server.del_member(server_pid, "Eliot2")
		assert %Group{group_name: groupname, num_people: 1, people:
			%{uniquename => eliot}} == Server.get_group(server_pid)

		# Test get member by getting a copy of eliot.
		assert eliot == Server.get_member(server_pid, uniquename)

		# Visually inspect the well defined data in test file SomePeople.txt.
		# Unique names are Selena and Eliot.
		path = "C:\\Users\\Michael\\ElixirProjects\\socialnetwork\\lib\\SomePeople.txt"
		Server.from_file!(server_pid, path)
	end
end  # End Test Group Server
