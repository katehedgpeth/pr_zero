defmodule PrZero.GithubCase do
  @moduledoc """
  Helper for tests that call the Github API.
  Sets up :user, :bypass, and :token.
  Use tags to change defaults:

  - `@tag :external` will set https://api.github.com as the base API url.
  - `@tag :bypass` or `@tag bypass: :base_api_url` will use Bypass for the base API url.
  - `@tag bypass: :base_auth_url` will use Bypass for the base Authorization url.
  - `@tag :log_api_calls?` will set the env var `log_api_calls?: true`
  - `@tag fetch_user: false will skip calling the API to get a user
  """
  use ExUnit.CaseTemplate
  use PrZero.Github.Aliases

  @overrideable_methods mock_file_path: 2,
                        set_mock: 1,
                        bypass_endpoint: 2,
                        get_endpoint_response: 2

  using _opts do
    quote do
      require Logger
      use PrZero.Github.Aliases
      alias PrZero.GithubCase
      alias Plug.Conn

      @orgs ["insurify", "kate-test-org"]

      @repos %{
        "insurify" => ["ensurify"],
        "kate-test-org" => ["pr_zero"]
      }

      @all_mocks Enum.reduce(
                   @orgs,
                   [
                     User,
                     Notifications,
                     Orgs
                   ],
                   fn org, acc1 ->
                     @repos
                     |> Map.fetch!(org)
                     |> Enum.reduce(
                       [
                         {Repos, %{org: org}} | acc1
                       ],
                       fn repo, acc2 -> [{Pulls, %{org: org, repo: repo}} | acc2] end
                     )
                   end
                 )

      setup tags do
        token = TestHelpers.get_test_token()

        bypass = set_github_host(tags)
        set_mocks(%{tags: tags, bypass: bypass, token: token})
        maybe_log_api_calls(tags, Github.env())
        user = User.get(token)

        {:ok, bypass: bypass, token: token, user: user}
      end

      defp set_mocks(%{tags: %{mock: false}}), do: :ok

      defp set_mocks(%{tags: %{mock: :all}} = opts) do
        opts
        |> put_in([:tags, :mock], @all_mocks)
        |> set_mocks()
      end

      defp set_mocks(%{tags: %{mock: endpoint}} = opts) when is_atom(endpoint) do
        opts
        |> put_in([:tags, :mock], [endpoint])
        |> set_mock()
      end

      defp set_mocks(%{tags: %{mock: [_ | _]}} = opts) do
        set_mock(opts)
      end

      defp set_mocks(%{tags: %{}}), do: :ok

      def bypass_endpoint(%Conn{req_headers: headers, request_path: req_path} = conn, %{
            response: "" <> response,
            token: token
          }) do
        ratelimit_reset =
          "Etc/UTC"
          |> DateTime.now!()
          |> Map.update!(:hour, &(&1 + 1))
          |> DateTime.to_unix()
          |> Integer.to_string()

        req_id = Float.to_string(:rand.uniform() * 1_000_000_000_000)

        with_headers =
          conn
          |> Conn.put_resp_header("X-GitHub-Media-Type", "github.v3")
          |> Conn.put_resp_header("X-GitHub-Request-Id", req_id)
          |> Conn.put_resp_header("X-RateLimit-Reset", ratelimit_reset)
          |> Conn.put_resp_header("X-RateLimit-Resource", "core")
          |> Conn.put_resp_header("X-RateLimit-Used", "1")
          |> Conn.put_resp_header("Server", "Bypass")

        case Enum.into(headers, %{}) do
          %{"authorization" => "Bearer " <> ^token} ->
            with_headers
            |> Conn.put_resp_header("X-RateLimit-Limit", "5000")
            |> Conn.put_resp_header("X-RateLimit-Remaining", "4999")
            |> Conn.send_resp(200, response)

          header_map ->
            with_headers
            |> Conn.put_resp_header(
              "X-Mocked-ReceivedToken",
              Map.get(header_map, "authorization")
            )
            |> Conn.put_resp_header("X-Mocked-ExpectedToken", "Bearer " <> token)
            |> Conn.put_resp_header("X-RateLimit-Limit", "60")
            |> Conn.put_resp_header("X-RateLimit-Remaining", "59")
            |> Conn.send_resp(
              :unauthorized,
              Jason.encode!(%{
                message: "Bad credentials",
                documentation_url: "https://docs.github.com/rest"
              })
            )
        end
      end

      def mock_file_path(endpoint, %{} = opts) when is_atom(endpoint),
        do: endpoint.mock_file_path(opts)

      def set_mock(%{tags: %{mock: []}}), do: :ok

      def set_mock(%{tags: %{mock: [endpoint | rest]} = tags, bypass: %Bypass{} = bypass} = opts)
          when is_atom(endpoint) do
        opts
        |> put_in([:tags, :mock], [{endpoint, %{}} | rest])
        |> set_mock()
      end

      def set_mock(
            %{tags: %{mock: [{endpoint, endpoint_opts} | rest]} = tags, bypass: %Bypass{}} = opts
          )
          when is_atom(endpoint) do
        opts = Map.put(opts, :response, get_endpoint_response(endpoint, endpoint_opts))

        Bypass.stub(
          opts.bypass,
          "GET",
          get_endpoint(tags),
          &bypass_endpoint(&1, opts)
        )

        opts
        |> put_in([:tags, :mock], rest)
        |> set_mock()
      end

      @spec get_endpoint_response(atom(), Map.t()) :: String.t()
      def get_endpoint_response(endpoint, %{} = opts) when is_atom(endpoint) do
        endpoint
        |> mock_file_path(opts)
        |> File.read!()
      end

      def get_endpoint(%{mock: [{endpoint, opts} | _]}), do: endpoint.endpoint(opts)

      def set_github_host(%{mock: [_ | _]}), do: set_github_host(%{mock: true})
      def set_github_host(%{mock: :all}), do: set_github_host(%{mock: true})

      def set_github_host(%{mock: true}) do
        bypass = Bypass.open()
        TestHelpers.set_github_host(bypass, :base_api_url)
        TestHelpers.set_github_host(bypass, :base_auth_url)
        bypass
      end

      def set_github_host(%{}) do
        TestHelpers.set_github_host(:github)
        nil
      end

      def maybe_log_api_calls(%{log_api_calls?: true}, env) do
        do_maybe_log_api_calls(true, env)
      end

      def maybe_log_api_calls(%{}, env) do
        do_maybe_log_api_calls(false, env)
      end

      def do_maybe_log_api_calls(bool, env) do
        updated = Keyword.update!(env, :log_api_calls?, fn _ -> bool end)
        Application.put_env(:pr_zero, PrZero.Github, updated)
      end

      defoverridable unquote(@overrideable_methods)
    end
  end
end
