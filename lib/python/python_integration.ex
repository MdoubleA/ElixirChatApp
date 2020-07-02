defmodule PythonIntegration do
	@moduledoc """
	Documentation for `PythonIntegraton`.
	"""

	@doc """
	Hello world.

	## Examples

	  iex> PythonIntegraton.hello()
	  :world

	"""
	def hello do
		:world
	end

	def test_python_integration do
		# Paths need to be character strings apparently.
		# For these tests to work will need adjust venv path.
		py_env = '.\\lib\\python\\venv\\Scripts\\python.exe'
		py_src = '.\\lib\\python'
		persona = [
			"Im the worlds most decorated olympian.",
			"The Arizona State Sun Devils are my favorite team. I volunteer there.",
			"I like to party; no else likes me partying. But I like to party."
		]  # End history
		history = []
		greeting = "hello! how are you?"
		reply = "how was the party?"

		{:ok, pid} = :python.start([{:python, py_env}, {:python_path, py_src}])

		{response, history} = :python.call(pid, :interface, :respond, [persona, history, greeting])
		response = List.to_string(response)  # Python character list to python string.
		IO.puts("------")
		IO.inspect(response)
		IO.inspect(history)

		{response, history} = :python.call(pid, :interface, :respond, [persona, history, reply])
		IO.inspect(response)
		IO.inspect(history)
		:python.stop(pid)
	end
end  # End Module.
