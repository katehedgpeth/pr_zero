defmodule PrZeroWeb.Plugs.User do
  @behaviour Plug
  require Logger
  alias PrZero.{Github, State}
  alias Plug.Conn
  import Conn

  def init([]) do
    []
  end

  def call(%Conn{assigns: %{github_token: token}} = conn, []) do
    case State.Users.get(token) do
      :error ->
        {:ok, user} = Github.User.get(token)
        {:ok, %State.User{}} = State.Users.create(user)
        assign(conn, :user, user)

      {:ok, %State.User{user_data: user}} ->
        assign(conn, :user, user)
    end
  end
end
