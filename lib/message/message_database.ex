defmodule Socialnetwork.MessageDatabase do
	use GenServer
	@db_folder ".\\persist\\Messages"
	alias Socialnetwork.MessageDatabase.Worker, as: Worker

	# Interface, these are called in the client process.
	def start_link(_) do
		GenServer.start(__MODULE__, nil, name: __MODULE__)
	end

	# Used in the testing functions.
	def start do
		GenServer.start(__MODULE__, nil, name: __MODULE__)
	end

	def store(key, data) do
		# Enter DB process              |> Enter worker process
		GenServer.call(__MODULE__, {:get, key}) |> Worker.store(key, data)
	end

	def get(key) do
		GenServer.call(__MODULE__, {:get, key}) |> Worker.get(key)
	end

	# Process callbacks --------------------------------------------------------
	# Need to optimize init to ensure it doesn't black any callers. See Chap 7.
	def init(_) do
		workers = 0..2
			|> Enum.map(fn id ->
		 			{:ok, pid} = Worker.start(@db_folder)
		 			{id, pid}
		 		end)
			|> Enum.into(%{})

		{:ok, workers}
	end

	def handle_call({:get, key}, _, workers) do
		worker_key = :erlang.phash2(key, Enum.count(workers))
		{:reply, Map.get(workers, worker_key), workers}
	end
end  # End UserDatabase Module
