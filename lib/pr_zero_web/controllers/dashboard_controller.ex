defmodule PrZeroWeb.DashboardController do
  require Logger
  use PrZeroWeb, :controller
  alias PrZero.Github
  alias Github.{User, Notifications}

  action_fallback PrZeroWeb.FallbackController

  def index(conn, %{"token" => token}) do
    {:ok, user} = User.get(token: token)
    {:ok, notifications} = Notifications.get(user)
    render(conn, "index.html", token: token, notifications: notifications)
  end
end
