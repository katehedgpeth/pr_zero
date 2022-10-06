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

  using _opts do
    quote do
      use PrZero.Github.Aliases
    end
  end

  setup tags do
    token = TestHelpers.get_test_token()

    bypass = set_github_host(tags)
    maybe_log_api_calls(tags, Github.env())
    user = maybe_get_user(tags, token, bypass)

    {:ok, bypass: bypass, token: token, user: user}
  end

  defp maybe_get_user(%{fetch_user: false}, _token, _bypass) do
    nil
  end

  defp maybe_get_user(tags, token, %Bypass{} = bypass) do
    TestHelpers.bypass_user(bypass, token)
    maybe_get_user(tags, token, nil)
  end

  defp maybe_get_user(%{}, token, _) do
    {:ok, %User{} = user} = User.get(token: token)
    user
  end

  defp set_github_host(%{external: true}) do
    TestHelpers.set_github_host(:github)
    nil
  end

  defp set_github_host(%{}) do
    bypass = Bypass.open()
    TestHelpers.set_github_host(bypass, :base_api_url)
    TestHelpers.set_github_host(bypass, :base_auth_url)
    bypass
  end

  defp maybe_log_api_calls(%{log_api_calls?: true}, env) do
    do_maybe_log_api_calls(true, env)
  end

  defp maybe_log_api_calls(%{}, env) do
    do_maybe_log_api_calls(false, env)
  end

  defp do_maybe_log_api_calls(bool, env) do
    updated = Keyword.update!(env, :log_api_calls?, fn _ -> bool end)
    Application.put_env(:pr_zero, PrZero.Github, updated)
  end
end
