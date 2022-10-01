defmodule PrZero.Github do
  @moduledoc """
  The Github context.
  """

  alias __MODULE__.Auth

  @access_token_endpoint "/login/oauth/access_token"

  @type access_token() :: Auth.token()
  @type code() :: String.t()

  @spec env :: [
          {:client_id, String.t()},
          {:client_secret, String.t()},
          {:base_url, String.t()}
        ]
  def env, do: Application.get_env(:pr_zero, __MODULE__)

  @spec client_id :: String.t()
  def client_id, do: Keyword.fetch!(env(), :client_id)

  @spec base_url :: String.t()
  def base_url, do: Keyword.fetch!(env(), :base_url)

  @spec base_uri :: URI.t()
  def base_uri do
    base_url()
    |> URI.new!()
  end

  @spec access_token_endpoint :: String.t()
  def access_token_endpoint, do: @access_token_endpoint

  @spec get_access_token([{:code, any} | {:cookie, any}]) ::
          {:error, HTTPoison.Error.t()} | {:ok, Auth.t()}
  def get_access_token(code: code, cookie: cookie) do
    base_url()
    |> Kernel.<>(@access_token_endpoint)
    |> HTTPoison.post(
      build_access_token_body(code: code),
      [{"Accept", "application/json"}, {"content-type", "application/json"}],
      hackney: [cookie: [cookie]]
    )
    |> parse_token_response(code)
  end

  @spec build_access_token_body([{:code, String.t()}]) :: String.t()
  defp build_access_token_body(code: code),
    do:
      env()
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
          | {:error, HTTPoison.Error.t()}
          | {:error, HTTPoison.Response.t()}
          | {:error, any()}
  defp parse_token_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, code) do
    body
    |> Jason.decode()
    |> case do
      {:ok, %{"access_token" => token}} -> {:ok, %Auth{token: token}}
      {:ok, %{"error" => "bad_verification_code"}} -> {:error, {:bad_verification_code, code}}
      {:ok, unexpected_body} -> {:error, {:unexpected_body, unexpected_body}}
      error -> error
    end
  end

  defp parse_token_response({:ok, %HTTPoison.Response{} = bad_response}, _),
    do: {:error, bad_response}

  defp parse_token_response({:error, %HTTPoison.Error{} = error}, _), do: {:error, error}
end
