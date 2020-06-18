defmodule Socialnetwork.MessageDatabase.Worker do
	use GenServer
	alias Socialnetwork.ProcessRegistry, as: ProcReg
	# This is the interface to the disk based database. Only does reads/writes.

	# Process interface --------------------------------------------
	# Functions for third party registration.
	# worker_id = {Worker, worker_id}
	def start_link({db_folder, worker_id}) do
		#IO.puts("Starting database worker #{worker_id}.")
		GenServer.start_link(
			__MODULE__,
			db_folder,
			name: via_tuple(worker_id)
		)
	end

	def store(worker_id, key, data) do
		GenServer.cast(via_tuple(worker_id), {:store, key, data})
	end

	def get(worker_id, key) do
		GenServer.call(via_tuple(worker_id), {:get, key})
	end

	defp via_tuple(worker_id) do
		ProcReg.via_tuple({__MODULE__, worker_id})
	end

	# Process callbacks --------------------------------------------------------
	def init(db_folder) do
		#IO.inspect(self())
		#IO.puts("Starting database worker.")
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
