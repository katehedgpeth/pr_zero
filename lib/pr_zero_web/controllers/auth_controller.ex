defmodule PrZeroWeb.AuthController do
  use PrZeroWeb, :controller

  alias PrZero.Github
  alias PrZero.Github.Auth

  action_fallback PrZeroWeb.FallbackController

  def index(conn, _params) do
    auth = Github.list_auth()
    render(conn, "index.json", auth: auth)
  end

  def create(conn, %{"auth" => auth_params}) do
    with {:ok, %Auth{} = auth} <- Github.create_auth(auth_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.auth_path(conn, :show, auth))
      |> render("show.json", auth: auth)
    end
  end

  def show(conn, %{"id" => id}) do
    auth = Github.get_auth!(id)
    render(conn, "show.json", auth: auth)
  end

  def delete(conn, %{"id" => id}) do
    auth = Github.get_auth!(id)

    with {:ok, %Auth{}} <- Github.delete_auth(auth) do
      send_resp(conn, :no_content, "")
    end
  end
end
