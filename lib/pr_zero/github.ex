defmodule PrZero.Github do
  @moduledoc """
  The Github context.
  """

  @spec env :: [
          {:client_id, String.t()},
          {:client_secret, String.t()},
          {:base_api_url, String.t()}
        ]
  def env, do: Application.get_env(:pr_zero, __MODULE__)

  @spec client_id :: String.t()
  def client_id, do: Keyword.fetch!(env(), :client_id)

  @spec base_url :: String.t()
  def base_url, do: Keyword.fetch!(env(), :base_api_url)

  @spec base_uri :: URI.t()
  def base_uri do
    base_url()
    |> URI.new!()
  end

  @type parsed_response() ::
          {:ok, Map.t()} | {:error, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}

  @spec get(URI.t()) :: parsed_response()
  @spec get(URI.t(), Map.t()) :: parsed_response()
  def get(%URI{} = endpoint), do: get(endpoint, %{})

  def get(%URI{} = endpoint, %{} = header_map) do
    endpoint
    |> build_url()
    |> HTTPoison.get(headers(header_map))
    |> parse_github_response()
  end

  @spec post(URI.t(), String.t()) :: parsed_response()
  @spec post(URI.t(), String.t(), Map.t()) :: parsed_response()
  def post(%URI{} = endpoint, "" <> body), do: post(endpoint, body, %{})

  def post(%URI{} = endpoint, "" <> body, %{} = header_map) do
    endpoint
    |> build_url()
    |> HTTPoison.post(body, headers(header_map))
    |> parse_github_response()
  end

  defp build_url(%URI{} = uri) do
    base_uri()
    |> URI.merge(uri)
    |> URI.to_string()
  end

  defp headers(%{token: _} = headers) do
    {token, rest} = Map.pop!(headers, :token)
    [{"Authorization", "Bearer " <> token} | headers(rest)]
  end

  defp headers(%{cookie: _} = headers) do
    {cookie, rest} = Map.pop!(headers, :cookie)
    [{"Cookie", cookie} | headers(rest)]
  end

  defp headers(%{}) do
    [{"Accept", "application/json"}]
  end

  @spec parse_github_response({:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}) ::
          parsed_response()
  defp parse_github_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}),
    do: Jason.decode(body)

  defp parse_github_response({:ok, %HTTPoison.Response{} = response}),
    do: {:error, response}

  defp parse_github_response(error),
    do: error
end
