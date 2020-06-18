defmodule Socialnetwork.MessageBoard.System do
	alias Socialnetwork.ProcessRegistry, as: ProcReg
	alias Socialnetwork.MessageDatabase, as: Db
	alias Socialnetwork.MessageBoardCache, as: Cache

	def start_link do
		# returns {:ok, Supervisor_pid}
		Supervisor.start_link(
			[
				ProcReg,
				Db,
				Cache
			],
			strategy: :one_for_one
		)
	end # End start_link
end # End MessageBoard.System
