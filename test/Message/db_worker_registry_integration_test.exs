defmodule DatabaseWorkerRegistryIntegrationTest do
	use ExUnit.Case
	alias Socialnetwork.ProcessRegistry, as: ProcReg
	alias Socialnetwork.MessageDatabase.Worker, as: Worker

	test "Database Worker Registry Integration" do
		# Test state initialization.
		sys_super = Process.whereis(Socialnetwork.MessageBoard.System)
		[{worker_1, nil}] = Registry.lookup(ProcReg, {Worker, 1})
		[{worker_2, nil}] = Registry.lookup(ProcReg, {Worker, 2})
		[{worker_3, nil}] = Registry.lookup(ProcReg, {Worker, 3})

		# Make sure all processe are alive and different.
		assert Process.alive?(worker_1)
		assert Process.alive?(worker_2)
		assert Process.alive?(worker_3)
		assert worker_1 != worker_2 != worker_3

		# Ensure worker restart after worker power down.------------------------
		Process.exit(worker_1, :kill)
		Process.exit(worker_2, :kill)
		Process.exit(worker_3, :kill)

		# Give the database supervisor some time to revive them all.
		Process.sleep(1000)

		# Check all processes old pids are off.
		assert Process.alive?(worker_1) == false
		assert Process.alive?(worker_2) == false
		assert Process.alive?(worker_3) == false

		# Check all processes are alive, under different pids.
		[{worker_1, nil}] = Registry.lookup(ProcReg, {Worker, 1})
		[{worker_2, nil}] = Registry.lookup(ProcReg, {Worker, 2})
		[{worker_3, nil}] = Registry.lookup(ProcReg, {Worker, 3})
		assert Process.alive?(worker_1) == true
		assert Process.alive?(worker_2) == true
		assert Process.alive?(worker_3) == true

		# Ensure database AND worker restart after database power down.---------
		# Power down database process.
		#sys_super = Process.whereis(:init)
		[{_, _, _, [_]}, {_, db_pid, _, [_]}, {_, _, _, [_]}] = Supervisor.which_children(sys_super)
		Process.exit(db_pid, :kill)

		# Give it time to be restarted and to restart its children.
		Process.sleep(1000)
		[{worker_12, nil}] = Registry.lookup(ProcReg, {Worker, 1})
		[{worker_22, nil}] = Registry.lookup(ProcReg, {Worker, 2})
		[{worker_32, nil}] = Registry.lookup(ProcReg, {Worker, 3})

		# Test that database children were indeed killed.
		assert Process.alive?(worker_1) == false
		assert Process.alive?(worker_2) == false
		assert Process.alive?(worker_3) == false

		# Double check childern are alive under different pids.
		assert worker_1 != worker_12
		assert worker_2 != worker_22
		assert worker_3 != worker_32

		# Shut down supervisor and ensure all children shut down.---------------
		# [{_, _, _, [_]}, {_, db_pid, _, [_]}, {_, _, _, [_]}] = Supervisor.which_children(sys_super)
		# IO.inspect(worker_12)
		# IO.inspect(worker_22)
		# IO.inspect(worker_32)
		# IO.inspect(Supervisor.which_children(db_pid))
		#
		#
		#
		# Process.exit(sys_super, :kill)
		# #Application.stop(Socialnetwork.MessageBoard.System)
		# Process.sleep(5000)
		# IO.inspect(Process.alive?(db_pid))
		#
		# # assert Process.alive?(worker_12) == false
		# # assert Process.alive?(worker_22) == false
		# # assert Process.alive?(worker_32) == false
		# #Application.start(Socialnetwork.MessageBoard.System)
		# Socialnetwork.MessageBoard.System.start_link()
		# Process.sleep(5000)
	end
end # End TestDatabaseWorker
