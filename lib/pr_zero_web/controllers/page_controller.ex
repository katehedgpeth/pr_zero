defmodule PrZeroWeb.PageController do
  use PrZeroWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
