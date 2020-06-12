defmodule Router do

def start(), do: spawn(fn -> loop({}) end)

defp loop(some_state) do
  new_state =
    receive do
      packet -> unpack(packet, some_state)
    end

    loop(new_state)
end

defp unpack(packet, _state) do
  case packet do
    {sender_pid, "Hello?"} -> send(sender_pid, {self(), "Hi!"})

    # For testing . . .
    {sender_pid, :test, mssg} -> test_base_routing(sender_pid, mssg)
  end
end

# Tests ------------------------------------------------------------------------

def test_loop_start() do
  router_pid = start()
  send(router_pid, {self(), :test, "Hello?"})
  my_pid = self()
  result = receive do
    {r_pid, m_pid, "Hi!"} -> if my_pid == m_pid and router_pid == r_pid, do: {:ok, "Sender: Success."}, else: {:error, "Sender: Fail, wrond return PIDs."}
    _ -> {:error, "Sender: Fail, wrong return packet."}
  end
  IO.inspect(result)
  :end
end

defp test_base_routing(sender_pid, mssg) do
  result = if mssg == "Hello?", do: {:ok, "Router: Success."}, else: {:error, "Fail."}
  IO.inspect(result)
  send(sender_pid, {self(), sender_pid, "Hi!"})
end


end
