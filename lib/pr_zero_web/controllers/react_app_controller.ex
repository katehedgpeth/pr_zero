defmodule PrZeroWeb.ReactAppController do
  require Logger
  alias Plug.Conn
  use PrZeroWeb, :controller

  action_fallback PrZeroWeb.FallbackController

  @react_app :pr_zero
             |> Application.app_dir("priv/static/react_app/index.html")
             |> File.read!()

  def index(%Conn{query_params: %{"token" => ""}} = conn, %{}) do
    render_forbidden(conn)
  end

  def index(%Conn{query_params: %{"token" => token}} = conn, %{}) do
    conn
    |> set_token_cookie(token)
    |> redirect(to: Routes.react_app_path(conn, :index))
  end

  def index(%Conn{body_params: %{"token" => token}} = conn, %{}) do
    conn
    |> set_token_cookie(token)
    |> redirect(to: Routes.react_app_path(conn, :index))
  end

  def index(%Conn{cookies: %{"github_token" => token}, query_string: ""} = conn, %{}) do
    conn
    |> set_token_cookie(token)
    |> put_resp_content_type("text/html")
    |> send_resp(200, @react_app)
  end

  def index(conn, %{}) do
    render_forbidden(conn)
  end

  defp set_token_cookie(conn, "" <> token) do
    put_resp_cookie(conn, "github_token", token)
  end

  defp render_forbidden(conn) do
    conn
    |> fetch_session()
    |> fetch_flash()
    |> put_status(:forbidden)
    |> render("index.html")
  end
end
