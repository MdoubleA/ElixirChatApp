defmodule Socialnetwork.MessageBoardCache do
	alias Socialnetwork.MessageServer, as: MessageServer
	# The cash will have a manager of some sort to handle Mapping user names to
	# unique ids. This is just a mapping of unique ids to pid's. If the system were
	# to get big, this process is used to synchronize unique key managment.

	
	def start_link(_) do
		# {:ok, supervisor_pid}
		IO.puts("Starting Message Cache.")
		DynamicSupervisor.start_link(
			name: __MODULE__,
			strategy: :one_for_one
		)
	end

	defp start_child(id) do
		DynamicSupervisor.start_child(
			__MODULE__,
			{MessageServer, id}
		)
	end

	def child_spec(_) do
		%{
			# How supervisor referes to child.
			id: __MODULE__,
			# The module, function, and arg list, module.function/args, to call on child creation.
			start: {__MODULE__, :start_link, []},
			# The type of process the child is.
			type: :supervisor
		}
	end

	# def get_messageboard(board_name) do
	# 	GenServer.call(__MODULE__, {:get, board_name})
	# end

end  # End Message Board Cache
