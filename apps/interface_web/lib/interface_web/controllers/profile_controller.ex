defmodule InterfaceWeb.ProfileController do
  use InterfaceWeb, :controller

  #alias Slax.History
  #alias Slax.History.Message

  #action_fallback ChatWeb.FallbackController Figure this thing out.

  def index(conn, _params) do
    profiles = Socialnetwork.Group.BotRepo.get_all()#History.list_messages() ## customize this.
    render(conn, "index.json", profiles: profiles)
  end

  # def create(conn, %{"message" => message_params}) do
  #   with {:ok, %Message{} = message} <- History.create_message(message_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.message_path(conn, :show, message))
  #     |> render("show.json", message: message)
  #   end
  # end
  #
  # def show(conn, %{"id" => id}) do
  #   message = History.get_message!(id)
  #   render(conn, "show.json", message: message)
  # end
  #
  # def update(conn, %{"id" => id, "message" => message_params}) do
  #   message = History.get_message!(id)
  #
  #   with {:ok, %Message{} = message} <- History.update_message(message, message_params) do
  #     render(conn, "show.json", message: message)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   message = History.get_message!(id)
  #
  #   with {:ok, %Message{}} <- History.delete_message(message) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
