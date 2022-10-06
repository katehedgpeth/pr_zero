defmodule PrZero.GithubTest do
  use PrZero.GithubCase
  alias PrZero.Github

  def get_token do
    {:ok,
     token:
       :pr_zero
       |> Application.get_env(:personal_access_tokens)
       |> Keyword.fetch!(:test_pat_notifications)}
  end

  describe "Github.get/2 - requests to api.github.com" do
    setup do
      get_token()
    end

    @tag :external
    test "returns {:ok, body}", %{token: token} do
      assert {:ok, %{"name" => _}} = Github.get(%URI{path: "/user"}, %{token: token})
    end

    @tag :external
    test "returns {:error, %HTTPoison.Response{}} when token is invalid" do
      assert {:error,
              %HTTPoison.Response{status_code: 401, body: "{\"message\":\"Bad credentials\"" <> _}} =
               Github.get(%URI{path: "/user"}, %{token: "BAD_TOKEN"})
    end
  end
end
