defmodule Socialnetwork.ProcessRegistry do

	# This allows the registry process to be supervised.
	def start_link do
		Registry.start_link(keys: :unique, name: __MODULE__)
	end

	# This works with start_link in allowing supervision. This configures "how"
	# to supervise. We don't care how it's supervised, so defer to it.
	def child_spec(_) do
		Supervisor.child_spec(
			Registry,
			id: __MODULE__,
			start: {__MODULE__, :start_link, []}
		)
	end

	# This configures the process registration process, to something other than
	# the defualt by module name method (name: __MODULE__) that registers the Process
	# in the entire beam instance. Allows the process to register itself in Registry.
	def via_tuple(key) do
		{:via, Registry, {__MODULE__, key}}
	end

end # End ProcessRegistry
