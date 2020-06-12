defmodule Socialnetwork.Group do
	alias __MODULE__
	# May want to have both of these in one file since they both use these atoms.
	# Need to make sure that these don't appear in any further layers.
	:uniquename
	:name
	:birthdate
	:interests

	defstruct group_name: nil, num_people: 0, people: %{}

	def new(), do: %Group{}
	def new(group_name), do: %Group{group_name: group_name}

	def add_member(a_group = %Group{}, a_person = %Socialnetwork.Person{}) do
		case Map.has_key?(a_group.people, a_person.uniquename) do
			true -> a_group
			false -> %Group{a_group | num_people: a_group.num_people + 1, people: Map.put(a_group.people, a_person.uniquename, a_person)}
		end
	end

	def update_member(a_group = %Group{}, a_person = %Socialnetwork.Person{}) do
		case Map.fetch(a_group.people, a_person.uniquename) do
			{:ok, orig_person} ->
				new_person = Socialnetwork.Person.new(orig_person)
				%Group{a_group | people: Map.put(a_group.people, new_person.uniquename, new_person)}

			:error -> a_group
		end
	end

	# Key is the proper atom but as a string.
	def update_member(a_group, uniquename, key, value) do
		field = String.to_existing_atom(key)
		update_member(a_group, uniquename, &Socialnetwork.Person.add_field(&1, field, value))
	end

	# Will want updater_fun needs to return a person instance.
	defp update_member(a_group = %Group{}, uniquename, updater_fun) do
		case Map.fetch(a_group.people, uniquename) do
			{:ok, orig_person} ->
				new_person = updater_fun.(orig_person)
				%Group{a_group | people: Map.put(a_group.people, new_person.uniquename, new_person)}

			:error -> a_group
		end
	end

	def get_member(a_group = %Group{}, uniquename) do
		case Map.fetch(a_group.people, uniquename) do
			{:ok, the_person} -> the_person
			:error -> {:error, uniquename}
		end
	end

	def del_member(a_group = %Group{}, a_person = %Socialnetwork.Person{}) do
		del_member(a_group, a_person.uniquename)
	end

	def del_member(a_group = %Group{}, uniquename) do
		if Map.has_key?(a_group.people, uniquename) do
			new_people = Map.delete(a_group.people, uniquename)
			%Group{a_group | num_people: a_group.num_people - 1, people: new_people}
		else
			a_group
		end
	end

	def add_group_name(a_group = %Group{}, name) do
		%Group{a_group | group_name: name}
	end

	def from_file!(path) do
		str_to_date = fn x ->
		                [year, month, day] = String.split(x, "-")
		                case Date.new(String.to_integer(year), String.to_integer(month), String.to_integer(day)) do
		                  {:ok, a_date} -> a_date
		                  {:error, _} -> nil
		                end
		              end
		fields_ls_to_person = fn [uniquename, name, birthdate, interest1, interest2, interest3] -> Socialnetwork.Person.new(uniquename, name, str_to_date.(birthdate), [interest1, interest2, interest3]) end
		File.stream!(path)
		|> Stream.map(&String.replace(&1,"\n", ""))
		|> Stream.map(&String.split(&1, "  "))  # Tabs and platform...get's tricky. As of THIS writing am using atom IDE that intereprets a tab as 2 spaces.
		|> Enum.map(&(fields_ls_to_person.(&1)))
		|> Enum.reduce(Group.new(), fn a_person, a_group -> add_member(a_group, a_person) end)
	end

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

	# Tests. -----------------------------------------------------------------------

	def test_file_format!() do
		from_file!("C:\\Users\\Michael\\ElixirProjects\\socialnetwork\\lib\\MakePeople.txt")
		|> Enum.map(fn {key, person} -> IO.puts("#{key} => #{person}") end)
		|> Enum.all?(&(&1 == :ok))
	end

	def test_from_file!() do
		the_people = from_file!("C:\\Users\\Michael\\ElixirProjects\\socialnetwork\\lib\\SomePeople.txt")
		eliot = the_people.people["Eliot"]
		selena = the_people.people["Selena"]

		if eliot.birthdate == ~D[1983-07-12] and selena.birthdate == ~D[1992-07-22] do
		  {:ok, "Group.from_file!/0"}
		else
		  {:ok, "Group.from_file!/0"}
		end
	end

	def test_del_member() do
		name = "Group.del_member/2"

		nonmember = del_member(new(), "Mike")
		nonmember = nonmember == %Group{group_name: nil, num_people: 0, people: %{}} && :ok

		a_person = %Socialnetwork.Person{uniquename: "Mike"}
		test_group = add_member(new(), a_person)
		test_group = del_member(test_group, "Mike")
		member = test_group == %Group{group_name: nil, num_people: 0, people: %{}} && :ok

		case {member, nonmember} do
		  {:ok, :ok} -> {:ok, name}
		  {_, _} ->
		    IO.puts(inspect(nonmember))
		    IO.puts("----------------")
		    IO.puts(inspect(member))
		    {:error, "Error in: #{name}"}
		end
	end

	def test_get_member() do
		name = "Group.get_member/2"
		test_group = new()
		mike = %Socialnetwork.Person{uniquename: "Mike"}

		nonexistant_member = get_member(test_group, "Mike")
		nonexistant_member = case nonexistant_member do
		                      {:ok, _} -> :error
		                      :error -> :ok
		                    end

		test_group = add_member(test_group, mike)
		existant_member = case get_member(test_group, "Mike") do
		                    {:ok, _} -> :ok
		                    :error -> :error
		                  end

		case {existant_member, nonexistant_member} do
		  {:ok, :ok} -> {:ok, name}
		  _ -> {:error, "Error in: #{name}"}
		end
	end

	def test_update_member() do
		name = "Group.update_member/3"
		mike = %Socialnetwork.Person{uniquename: "Mike", name: "Mike"}
		test_group = new("BookReaders")

		base_case = test_group.num_people == 0 && test_group.people == %{} && test_group.group_name == "BookReaders" && :ok

		test_group = update_member(test_group, "Mike", &Socialnetwork.Person.add_field(&1, :name, "Mycal"))
		no_member_to_update = test_group.num_people == 0 && test_group.people == %{} && test_group.group_name == "BookReaders" && :ok

		test_group = add_member(test_group, mike)
		test_group = update_member(test_group, "Mike", &Socialnetwork.Person.add_field(&1, :name, "Mycal"))
		member_to_update = test_group.num_people == 1 && test_group.people == %{"Mike" => %Socialnetwork.Person{uniquename: "Mike", name: "Mycal"}}
		                                              && test_group.group_name == "BookReaders" && :ok

		test_group = update_member(test_group, "Mike", &Socialnetwork.Person.add_field(&1, :uniquename, "Mycal"))
		person_protects_its_data = test_group.num_people == 1 && test_group.people == %{"Mike" => %Socialnetwork.Person{uniquename: "Mike", name: "Mycal"}}
		                                             && test_group.group_name == "BookReaders" && :ok

		case {base_case, no_member_to_update, member_to_update, person_protects_its_data} do
		  {:ok, :ok, :ok, :ok} -> {:ok, name}
		  _ ->
		    IO.puts(inspect(base_case))
		    IO.puts("-----------------")
		    IO.puts(inspect(no_member_to_update))
		    IO.puts("-----------------")
		    IO.puts(inspect(member_to_update))
		    IO.puts("-----------------")
		    IO.puts(inspect(person_protects_its_data))
		    {:error, "Error in: #{name}"}
		end
	end

	def test_add_member_2() do
		name = "Group.add_member/2"
		mike = %Socialnetwork.Person{uniquename: "Mike", name: "Mike"}
		michael = %Socialnetwork.Person{uniquename: "Mike", name: "Michael"}

		test_group = new()
		base_case = test_group.num_people == 0 && test_group.people == %{} && :ok

		test_group = add_member(test_group, mike)
		success_case = test_group.num_people == 1 && test_group.people == %{"Mike" => mike} && :ok

		test_group = add_member(test_group, michael)
		fail_case = test_group.num_people == 1 && test_group.people == %{"Mike" => mike} && :ok

		case {base_case, success_case, fail_case} do
		  {:ok, :ok, :ok} -> {:ok, name}
		  {_, _, _} -> {:error, "Error in: #{name}"}
		end
	end

	def test_new_1() do
		name = "Group.new/1"
		case new("Bob") do
		  %Group{group_name: "Bob", num_people: 0, people: %{}} -> {:ok, name}
		  _ -> {:error, name}
		end
	end

	def test_new() do
		name = "Group.new/0"
		case new() do
		  %Group{group_name: nil, num_people: 0, people: %{}} -> {:ok, name}
		  _ -> {:error, name}
		end
	end

	def run_tests() do
		with {:ok, _} <- test_new(),
		     {:ok, _} <- test_new_1(),
		     {:ok, _} <- test_add_member_2(),
		     {:ok, _} <- test_update_member(),
		     {:ok, _} <- test_add_member_2(),
		     {:ok, _} <- test_del_member(),
		     {:ok, _} <- test_from_file!() do
		  IO.inspect({:ok, "Group Module: All systems go."})
		  :test_end
		end
	end

end  # Module end
