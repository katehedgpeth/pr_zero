defmodule PrZeroWeb.Plugs.User do
  @behaviour Plug
  require Logger
  alias PrZero.Github.User
  alias Plug.Conn
  import Conn

  def init([]) do
    []
  end

  def call(%Conn{assigns: %{github_token: token}} = conn, []) do
    Logger.warn("token=#{token}")
    assign(conn, :user, User.get(token: token))
  end

  # def call(conn, []) do
  #   conn
  # end
end
