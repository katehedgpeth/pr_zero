defmodule PrZero.Github.Auth do
  alias Plug.Conn
  alias PrZero.Github
  alias PrZeroWeb.ConnHelpers

  @access_token_endpoint "/login/oauth/access_token"

  def base_auth_uri(),
    do:
      Github.env()
      |> Keyword.fetch!(:base_auth_url)
      |> URI.parse()

  @type token() :: String.t()
  @type code() :: String.t()
  @type t() :: %__MODULE__{token: token()}
  defstruct [
    :token
  ]

  @spec access_token_endpoint :: String.t()
  def access_token_endpoint, do: @access_token_endpoint

  @spec get_access_token([{:code, any} | {:cookie, any}]) ::
          {:error, HTTPoison.Error.t()} | {:ok, Auth.t()}
  def get_access_token(code: code, cookie: cookie) do
    base_auth_uri()
    |> URI.merge(%URI{path: @access_token_endpoint})
    |> Github.post(build_access_token_body(code: code), %{cookie: cookie})
    |> parse_token_response(code)
  end

  def oauthorize_url(%Conn{} = conn) do
    conn
    |> ConnHelpers.get_csrf_token()
    |> do_oauthorize_url()
  end

  def do_oauthorize_url({:ok, {csrf, conn}}) do
    base_auth_uri()
    |> URI.merge(%URI{
      path: "/login/oauth/authorize",
      query: encode_oauth_query(conn, csrf)
    })
    |> URI.to_string()
  end

  defp encode_oauth_query(%Conn{assigns: %{redirect_url: redirect_url}}, csrf) do
    do_encode_oauth_query(%{redirect_url: redirect_url}, csrf)
  end

  defp encode_oauth_query(%Conn{}, csrf) do
    do_encode_oauth_query(%{}, csrf)
  end

  defp do_encode_oauth_query(opts, csrf) do
    %{
      client_id: Github.client_id(),
      scope: "notifications",
      state: csrf
    }
    |> Map.merge(opts)
    |> URI.encode_query()
  end

  @spec build_access_token_body([{:code, String.t()}]) :: String.t()
  defp build_access_token_body(code: code),
    do:
      Github.env()
      |> Keyword.take([:client_id, :client_secret])
      |> Keyword.merge(code: code)
      |> Enum.into(%{})
      |> Jason.encode!()

  @spec parse_token_response(
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()},
          String.t()
        ) ::
          {:ok, Auth.t()}
          | {:error, {:bad_verification_code, code()}}
          | {:error, {:unexpected_body, Map.t()}}
          | {:error, HTTPoison.Response.t()}
          | {:error, HTTPoison.Error.t()}
  defp parse_token_response({:ok, %{"access_token" => token}}, _code),
    do: {:ok, %__MODULE__{token: token}}

  defp parse_token_response({:ok, %{"error" => "bad_verification_code"}}, code),
    do: {:error, {:bad_verification_code, code}}

  defp parse_token_response({:ok, unexpected_body}, _code),
    do: {:error, {:unexpected_body, unexpected_body}}

  defp parse_token_response({:error, error}, _code), do: {:error, error}
end
