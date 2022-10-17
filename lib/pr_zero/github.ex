defmodule PrZero.Github do
  @moduledoc """
  The Github context.
  """
  require Logger

  @mock_file_folder "./test/mocks/"

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

  @type error_response() :: {:error, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  @type parsed_response() ::
          {:ok, Map.t()} | error_response()

  @type mock_file_key() :: :repos | :orgs | :notifications | :pull_requests | :user | nil

  @spec get(URI.t()) :: parsed_response()
  @spec get(URI.t(), Map.t()) :: parsed_response()
  @spec get(URI.t(), Map.t(), mock_file_key()) :: parsed_response()

  def get(%URI{} = endpoint, %{} = header_map \\ %{}, key \\ nil) do
    endpoint
    |> build_url()
    |> HTTPoison.get(headers(header_map))
    |> log_rate_limit()
    |> parse_github_response(key)
  end

  @spec post(URI.t(), String.t()) :: parsed_response()
  @spec post(URI.t(), String.t(), Map.t()) :: parsed_response()
  @spec post(URI.t(), String.t(), Map.t(), mock_file_key()) :: parsed_response()

  def post(%URI{} = endpoint, "" <> body, %{} = header_map \\ %{}, key \\ nil) do
    endpoint
    |> build_url()
    |> HTTPoison.post(body, headers(header_map))
    |> log_rate_limit()
    |> parse_github_response(key)
  end

  def mock_file_path("" <> name) do
    @mock_file_folder
    |> Kernel.<>(name)
    |> Kernel.<>(".json")
    |> Path.relative_to_cwd()
    |> Path.expand()
  end

  defp build_url(%URI{} = uri) do
    base_uri()
    |> URI.merge(uri)
    |> URI.to_string()
    |> maybe_log_url(env() |> Enum.into(%{}))
  end

  defp maybe_log_url(url, %{log_api_calls?: true}) do
    Logger.warn("event=github_call url=#{url}")
    url
  end

  defp maybe_log_url(url, %{log_api_calls?: false}) do
    url
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

  @spec parse_github_response(
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()},
          mock_file_key()
        ) ::
          parsed_response()
  defp parse_github_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, key) do
    maybe_write_mock_file(body, key)
    Jason.decode(body)
  end

  defp parse_github_response({:ok, %HTTPoison.Response{} = response}, _key),
    do: {:error, response}

  defp parse_github_response(error, _key),
    do: error

  defp maybe_write_mock_file("" <> body, "" <> name, true) do
    path = mock_file_path(name)
    Logger.warn("Saving github response to " <> path)

    :ok = File.write(path, body)
  end

  defp maybe_write_mock_file("" <> _body, "" <> _name, _), do: :ok

  defp maybe_write_mock_file("" <> body, "" <> name),
    do: maybe_write_mock_file(body, name, Application.get_env(:pr_zero, :write_mock_file?))

  defp maybe_write_mock_file("" <> _body, nil), do: :ok

  defp maybe_write_mock_file("" <> body, name) when is_atom(name) do
    maybe_write_mock_file(body, Atom.to_string(name))
  end

  defp log_rate_limit(
         {:ok, %HTTPoison.Response{headers: headers, request: %HTTPoison.Request{url: url}}} =
           response
       ) do
    headers
    |> Enum.into(%{})
    |> do_log_rate_limit(url)

    response
  end

  defp log_rate_limit({:error, %HTTPoison.Error{}} = error), do: error

  defp do_log_rate_limit(
         %{
           "X-RateLimit-Limit" => limit_str,
           "X-RateLimit-Used" => used_str,
           "X-RateLimit-Remaining" => remaining_str,
           "X-RateLimit-Reset" => reset_str,
           "Server" => server
         },
         url
       ) do
    reset =
      reset_str
      |> String.to_integer()
      |> Timex.from_unix()
      |> Timex.shift(hours: -4)

    remaining = String.to_integer(remaining_str)

    message =
      %{
        "rate_limit" => limit_str,
        "remaining" => remaining_str,
        "used" => used_str,
        "reset_at" => reset,
        "server" => server,
        "url" => url
      }
      |> Enum.map(&Tuple.to_list/1)
      |> Enum.map(&Enum.join(&1, "="))
      |> Enum.join(" ")

    if remaining < 100, do: Logger.warn(message)
    if remaining >= 100, do: Logger.debug(message)
  end

  defp do_log_rate_limit(%{}, _url), do: :ok
end
