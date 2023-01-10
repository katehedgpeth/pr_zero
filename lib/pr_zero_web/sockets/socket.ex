defmodule PrZeroWeb.Socket do
  alias Phoenix.Socket
  alias PrZero.State
  use Socket

  channel "notifications:*", PrZeroWeb.NotificationsChannel

  @impl true
  def connect(%{"github_token" => token}, %Socket{} = socket, _connect_info) do
    {:ok, user} = get_user(token)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:github_token, token)}
  end

  @impl true
  def id(%Socket{assigns: %{github_token: token}}), do: "socket:" <> token

  defp get_user(token) do
    case State.Users.get(token) do
      :error ->
        token
        |> PrZero.Github.User.get()
        |> State.Users.create()

      user ->
        user
    end
  end
end
