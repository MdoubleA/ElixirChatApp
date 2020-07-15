defmodule Socialnetwork.MessageDatabase do
	@db_folder ".\\test\\persist\\Messages"
	@pool_size 3
	alias Socialnetwork.MessageDatabase.Worker, as: Worker
	use Supervisor

	# Interface, these are called in the client process.
	def start_link() do
		File.mkdir_p!(@db_folder)
		children = Enum.map(1..@pool_size, &worker_spec/1)
		Supervisor.start_link(__MODULE__, children, name: __MODULE__)
		#Supervisor.start_link(children, strategy: :one_for_one, )
	end

	defp worker_spec(worker_id) do
		default_worker_spec = {Worker, {@db_folder, worker_id}}
		Supervisor.child_spec(default_worker_spec, id: worker_id)
	end

	@impl true
	def init(children) do
	  Supervisor.init(children, strategy: :one_for_one)
	end

	def child_spec(_) do
		%{
			id: __MODULE__,
			start: {__MODULE__, :start_link, []},
			type: :supervisor  	# Allows MessageDatabase to be created as start_link/0
								# since it is a supervisor.
		}
	end

	# Used in the testing functions.
	# Used to dynamically get a pid for a given key (worker_id/key) since now pids can change.
	defp choose_worker(key) do
		:erlang.phash2(key, @pool_size) + 1 # +1 since not zero-indexing.
	end

	def store(key, data) do
		# Enter DB process              |> Enter worker process
		key |> choose_worker() |> Worker.store(key, data)
	end

	def get(key) do
		key |> choose_worker() |> Worker.get(key)
	end
end # End Socialnetwork.MessageDatabase
