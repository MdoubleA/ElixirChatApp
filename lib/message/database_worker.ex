defmodule Socialnetwork.MessageDatabase.Worker do
	use GenServer
	# This is the interface to the disk based database. Only does reads/writes.

	# Process interface --------------------------------------------------------
	def start(db_folder) do
		#IO.inspect(__MODULE__)
		GenServer.start(__MODULE__, db_folder)
		#{:ok, pid}
	end

	def store(pid, key, data) do
		GenServer.cast(pid, {:store, key, data})
	end

	def get(pid, key) do
		GenServer.call(pid, {:get, key})
	end

	# Process callbacks --------------------------------------------------------
	def init(db_folder) do
		File.mkdir_p!(db_folder)
		{:ok, db_folder}
	end

	def handle_cast({:store, key, data}, db_folder) do
		db_folder
		|> file_name(key)
		|> File.write!(:erlang.term_to_binary(data))

		{:noreply, db_folder}
	end

	def handle_call({:get, key}, _, db_folder) do
		data = case File.read(file_name(db_folder, key)) do
			{:ok, contents} -> :erlang.binary_to_term(contents)
			_ -> nil
		end

		{:reply, data, db_folder}
	end

	defp file_name(db_folder, key) do
		Path.join(db_folder, to_string(key))
	end
end  # End UserDatabase Module
