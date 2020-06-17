defmodule Socialnetwork.MessageDatabase do
	use GenServer
	@db_folder ".\\persist\\Messages"
	alias Socialnetwork.MessageDatabase.Worker, as: Worker

	# Interface, these are called in the client process.
	def start do
		{:ok, pid} = GenServer.start(__MODULE__, nil, name: __MODULE__)
		IO.inspect(pid)
	end

	def store(key, data) do
		# Enter DB process              |> Enter worker process
		GenServer.call(__MODULE__, key) |> Worker.store(key, data)
	end

	def get(key) do
		GenServer.call(__MODULE__, key) |> Worker.get(key)
	end

	# Process callbacks --------------------------------------------------------
	def init(_) do
		workers =
			0..2
			|> Enum.each(fn id ->
					{:ok, pid} = Worker.start(@db_folder)
					{id, pid}
				end)
			|> Enum.into(%{})

		{:ok, workers}
	end

	def handle_call({:get, key}, _, workers) do
		worker_pid = :erlang.phash(key, Enum.count(workers))
		{:reply, worker_pid, workers}
	end
end  # End UserDatabase Module
