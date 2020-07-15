defmodule InterfaceWeb.ProfileView do
  use InterfaceWeb, :view
  alias InterfaceWeb.ProfileView

  def render("index.json", %{profiles: profiles}) do
    %{data: render_many(profiles, ProfileView, "profile.json")}
  end

  # def render("show.json", %{message: message}) do
  #   %{data: render_one(message, MessageView, "message.json")}
  # end

  def render("profile.json", %{profile: profile}) do
	  # uniquename: nil, name: nil, birthdate: nil, interests: []
    %{uniquename: profile.uniquename,
      name: profile.name,
      birthdate: profile.birthdate,
      interests: profile.interests}
  end
end
