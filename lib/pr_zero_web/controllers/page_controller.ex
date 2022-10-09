defmodule PrZeroWeb.PageController do
  use PrZeroWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def options(conn, _params) do
    conn
  end
end
