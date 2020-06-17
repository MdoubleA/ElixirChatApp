defmodule TestUserRepository do
	use ExUnit.Case
	alias Socialnetwork.Group, as: Group
	alias Socialnetwork.Person, as: Person
	alias Socialnetwork.UserRepository, as: Repository
	# The code was copied and pasted from group server module, after it was tested.
	# So only testing changed functionality.
	# Make sure to delete database file associated with groupname before starting test.
	# i.e. .\persist\"groupname".

	test "User Repository" do
		groupname = "TestUserRepository"
		File.rm(".\\persist\\Users\\"<>groupname)

		# Test initialization creates properly formatted "blank slate."
		{:ok, server_pid} = Repository.start(groupname)
		assert %Group{group_name: groupname, num_people: 0, people: %{}}
			== Repository.get_group(server_pid)

		# Test name change and name persistance.
		# Will need to adjust this to be what name change does.
		# In fact, for this specific implementation of a Group, may be best to remove
		# This function.
		#assert :ok == Server.add_name(server_pid, groupname)
		#assert %Group{group_name: groupname, num_people: 0, people: %{}}
		#	== Server.get_group(server_pid)

		# Test Person addition and persistance.
		uniquename = "Star-Lord"
		name = "Chris Pratt"
		birthdate = "1979-06-21"
		interest1 = "My hobbies include fishing, hunting and working on cars."
		interest2 = "I was a military adviser to the Kree General Ronan the Accuser."
		starlord = Person.new(uniquename, name, birthdate, [interest1, interest2])

		# Add star-lord.
		assert :ok == Repository.add_member(server_pid, uniquename, name, birthdate,
			[interest1, interest2])
		assert %Group{group_name: groupname, num_people: 1, people:
			%{uniquename => starlord}} == Repository.get_group(server_pid)

		# Test delete function by deleteing star-lord.
		assert :ok == Repository.del_member(server_pid, uniquename)
		assert %Group{group_name: groupname, num_people: 0, people:
			%{}} == Repository.get_group(server_pid)

		# Test get member by getting a copy of star-lord, and double check add is still working.
		assert :ok == Repository.add_member(server_pid, uniquename, name, birthdate,
			[interest1, interest2])
		assert starlord == Repository.get_member(server_pid, uniquename)

		# Now add the data from .\lib\MakePeople.txt
		# And simultaneously test Repository.add_member/2
		main_repository = Group.from_file!(".\\lib\\MakePeople.txt")
		add_more_members = fn {_, person} -> Repository.add_member(server_pid, person) end
		Enum.each(main_repository, add_more_members)

		# Visually inspect the data.
		#IO.inspect(Repository.get_group(server_pid))
	end
end  # End Test Group Server
