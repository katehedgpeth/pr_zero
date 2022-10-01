defmodule PrZeroWeb.AuthController do
  require Logger
  use PrZeroWeb, :controller

  alias Plug.Conn

  alias PrZero.Github
  alias PrZero.Github.Auth

  action_fallback PrZeroWeb.FallbackController

  def index(conn, %{}) do
    csrf = Plug.CSRFProtection.get_csrf_token()

    url = github_oauthorize_url(conn, csrf)

    redirect(conn, external: url)
  end

  def create(%Conn{} = conn, %{"code" => code, "state" => csrf_token}) do
    case verify_csrf(conn, csrf_token) do
      :ok ->
        do_create(conn, %{code: code})

      {:error, {:mismatch, details}} ->
        render_error(conn, %{
          status: :not_authorized,
          message: Jason.encode_to_iodata!(details)
        })
    end
  end

  def create(%Conn{} = conn, _) do
    redirect(conn, to: Routes.auth_path(conn, :index))
  end

  def delete(conn, %{"id" => _}) do
    render_error(conn, %{status: :not_implemented, message: "Not Implemented"})
  end

  def github_oauthorize_url(%Conn{} = conn, "" <> csrf) do
    Github.base_uri()
    |> URI.merge(%URI{
      path: "/login/oauth/authorize",
      query:
        URI.encode_query(%{
          client_id: Github.client_id(),
          redirect_url: Routes.auth_url(conn, :create),
          scope: "notifications",
          state: csrf
        })
    })
    |> URI.to_string()
  end

  def get_csrf_token(%Conn{private: %{:plug_session => %{"_csrf_token" => csrf_token}}}),
    do: csrf_token

  defp verify_csrf(conn, csrf) do
    conn
    |> get_csrf_token()
    |> case do
      ^csrf -> :ok
      mismatch -> {:error, {:mismatch, expected: csrf, received: mismatch}}
    end
  end

  defp get_cookie_for_token(%Conn{} = conn) do
    conn
    |> Map.get(:req_headers)
    |> Enum.into(%{})
    |> Map.get("cookie")
  end

  defp cannot_authenticate_response(status) when is_atom(status) do
    %{
      status: status,
      message: "Unable to authenticate with GitHub"
    }
  end

  defp do_create(%Conn{} = conn, %{code: code}) do
    case Github.get_access_token(
           code: code,
           cookie: get_cookie_for_token(conn)
         ) do
      {:ok, %Auth{token: token}} ->
        conn
        |> assign(:token, token)
        |> redirect(to: Routes.page_path(conn, :index, token: token))

      {:error, {:bad_verification_code, _}} ->
        render_error(conn, cannot_authenticate_response(:forbidden))

      {:error, %HTTPoison.Response{status_code: status, body: body, headers: headers}} ->
        %{
          "error" => "unexpected_access_token_response",
          "status_code" => status,
          "body" => body,
          "headers" => headers |> Enum.into(%{}) |> Jason.encode!()
        }
        |> Enum.map(&Tuple.to_list/1)
        |> Enum.map(&Enum.join(&1, "="))
        |> Enum.join(" ")
        |> Logger.error()

        render_error(conn, cannot_authenticate_response(:bad_gateway))

      {:error, %HTTPoison.Error{reason: :econnrefused}} ->
        Logger.error("error=github_is_down")
        render_error(conn, cannot_authenticate_response(:service_unavailable))
    end
  end

  defp render_error(%Conn{} = conn, %{message: message, status: status}) do
    conn
    |> put_status(status)
    |> render("index.html", message: message)
  end
end
