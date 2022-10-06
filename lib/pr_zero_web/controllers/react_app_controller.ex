defmodule PrZeroWeb.ReactAppController do
  require Logger
  use PrZeroWeb, :controller

  action_fallback PrZeroWeb.FallbackController

  def index(conn, %{"token" => "" <> token}) when byte_size(token) > 30 do
    send_resp(conn, 200, render_react_app())
  end

  def index(conn, %{}) do
    conn
    |> put_status(:forbidden)
    |> render("index.html")
  end

  defp render_react_app() do
    :pr_zero
    |> Application.app_dir("priv/static/react_app/index.html")
    |> File.read!()
  end
end
