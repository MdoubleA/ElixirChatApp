defmodule TestRegistryIntegration do
	use ExUnit.Case
	alias Socialnetwork.ProcessRegistry, as: ProcReg
	alias Socialnetwork.MessageDatabase.Worker, as: Worker

	test "Registry Integration" do
		# Test state initialization.
		{:ok, sys_super} = Socialnetwork.MessageBoard.System.start_link()
		[{worker_1, nil}] = Registry.lookup(ProcReg, {Worker, 1})
		[{worker_2, nil}] = Registry.lookup(ProcReg, {Worker, 2})
		[{worker_3, nil}] = Registry.lookup(ProcReg, {Worker, 3})

		# Test process restart.
		# Make sure all processe are alive.
		assert Process.alive?(worker_1)
		assert Process.alive?(worker_2)
		assert Process.alive?(worker_3)

		# Kill all the processes.
		Process.exit(worker_1, :kill)
		Process.exit(worker_2, :kill)
		Process.exit(worker_3, :kill)

		# Give the supervisor some time to revive them all.
		Process.sleep(1000)

		# The pid's may change so grab again.
		[{worker_1, nil}] = Registry.lookup(ProcReg, {Worker, 1})
		[{worker_2, nil}] = Registry.lookup(ProcReg, {Worker, 2})
		[{worker_3, nil}] = Registry.lookup(ProcReg, {Worker, 3})

		# Check all processes are back alive.
		assert Process.alive?(worker_1) == true
		assert Process.alive?(worker_1) == true
		assert Process.alive?(worker_1) == true

		# Shut down supervisor and ensure all children shut down.
		Process.exit(sys_super, :normal)
		Process.sleep(1000)
		assert Process.alive?(worker_1) == false
		assert Process.alive?(worker_2) == false
		assert Process.alive?(worker_3) == false
	end
end # End TestDatabaseWorker
