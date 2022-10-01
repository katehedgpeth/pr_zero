defmodule TestHelpers do
  alias PrZero.Github
  alias Plug.Conn

  @spec set_github_host(Bypass.t() | URI.t()) :: :ok
  def set_github_host(%Bypass{port: port}) do
    set_github_host(%URI{
      scheme: "http",
      host: "localhost",
      port: port
    })
  end

  def set_github_host(%URI{} = uri) do
    Application.put_env(
      :pr_zero,
      Github,
      Keyword.update!(Github.env(), :base_url, fn _ -> URI.to_string(uri) end)
    )
  end

  def set_github_host(:github) do
    set_github_host(%URI{
      scheme: "https",
      host: "github.com"
    })
  end

  @type incorrect_github_domain() :: {:error, {:incorrect_domain, URI.t(), integer() | nil}}
  @type assert_github_url_return() ::
          {:ok, URI.t()} | incorrect_github_domain() | {:error, {atom(), any()}}

  @spec assert_github_url(URI.t(), Bypass.t()) ::
          assert_github_url_return()
  @spec assert_github_url(URI.t()) :: assert_github_url_return()
  def assert_github_url(
        %URI{
          scheme: "http",
          host: "localhost",
          port: port
        } = uri,
        %Bypass{port: port}
      ) do
    do_assert_github_url(uri)
  end

  def assert_github_url(%URI{} = error, %Bypass{port: port}, cb) when is_function(cb) do
    {:error, {:incorrect_domain, error, port}}
  end

  def assert_github_url(%URI{scheme: "https", host: "github.com", port: 443} = uri) do
    do_assert_github_url(uri)
  end

  def assert_github_url(%URI{} = uri) do
    {:error, {:incorrect_domain, uri, nil}}
  end

  defp do_assert_github_url(%URI{path: "/login/oauth/authorize"} = uri) do
    assert_github_query_params(uri, &assert_correct_authorize_query_params/2)
  end

  defp do_assert_github_url(
         %URI{
           path: "/login/oauth/access_token",
           query: nil
         } = uri
       ) do
    {:ok, uri}
  end

  defp do_assert_github_url(%URI{} = uri) do
    {:error, {:incorrect_path, uri}}
  end

  defp assert_github_query_params(%URI{query: query} = uri, validator)
       when is_function(validator) do
    query
    |> URI.decode_query()
    |> validator.(Github.env() |> Enum.into(%{}))
    |> case do
      :ok -> {:ok, uri}
      error -> error
    end
  end

  defp assert_correct_authorize_query_params(
         %{
           "client_id" => client_id,
           "redirect_url" => "http://localhost:4002/auth/authorized",
           "scope" => "notifications",
           "state" => "" <> _
         },
         %{client_id: client_id}
       ) do
    :ok
  end

  defp assert_correct_authorize_query_params(%{} = params, client_id) do
    {:error, {:incorrect_query, {params, client_id}}}
  end

  def get_redirect_uri(headers) when is_list(headers) do
    headers
    |> Enum.into(%{})
    |> Map.fetch!("location")
    |> URI.new!()
  end

  def bypass_access_token_success(%Bypass{} = bypass, %{} = code_and_token) do
    bypass_access_token_request(bypass, code_and_token)
  end

  def bypass_access_token_bad_code(%Bypass{} = bypass) do
    bypass_access_token_request(bypass, %{
      access_token: nil,
      code: "SHOULD_NOT_MATCH"
    })
  end

  def bypass_access_token_request(%Bypass{} = bypass, %{access_token: access_token, code: code}) do
    Bypass.expect_once(
      bypass,
      "POST",
      Github.access_token_endpoint(),
      fn %Conn{body_params: %Conn.Unfetched{}} = conn ->
        {:ok, body, conn} = Conn.read_body(conn)

        body
        |> Jason.decode()
        |> case do
          {:ok, %{"code" => ^code}} -> respond(conn, 200, %{access_token: access_token})
          {:ok, %{"code" => _}} -> respond(conn, 200, %{error: "bad_verification_code"})
          {:ok, _} -> respond(conn, 404, %{})
          {:error, %Jason.DecodeError{}} -> {:error, {:bad_body, body}}
        end
      end
    )
  end

  defp respond(%Conn{} = conn, status, %{} = payload) when is_integer(status) do
    Conn.resp(
      conn,
      status,
      Jason.encode!(payload)
    )
  end
end
