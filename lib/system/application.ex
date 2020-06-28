defmodule Socialnetwork.Application do
	use Application

	def start(_, _) do
		Socialnetwork.MessageBoard.System.start_link()
	end
end  # end module definition
