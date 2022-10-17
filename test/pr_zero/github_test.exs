defmodule PrZero.GithubTest do
  use PrZero.GithubCase
  alias PrZero.Github

  describe "Github.get/2 - requests to api.github.com" do
    setup _ do
      {:ok, token: TestHelpers.get_test_token()}
    end

    @tag mock: [User]
    test "returns {:ok, body}", %{token: token} do
      # assert {:ok, %{"name" => _}} = Github.get(%URI{path: "/user"}, %{token: token})

      level = Logger.get_module_level(Github)
      Logger.put_module_level(Github, :debug)

      log =
        ExUnit.CaptureLog.capture_log(fn ->
          assert {:ok, %{"name" => _}} = Github.get(%URI{path: "/user"}, %{token: token})
        end)

      assert log =~ "[debug]"
      assert log =~ "limit="
      assert log =~ "remaining="
      assert log =~ "used="
      assert log =~ "reset_at="
      Logger.put_module_level(Github, level)
    end

    # @tag :external
    @tag mock: [User]
    test "returns {:error, %HTTPoison.Response{}} when token is invalid" do
      log =
        ExUnit.CaptureLog.capture_log(fn ->
          assert {:error, %HTTPoison.Response{status_code: 401, body: body}} =
                   Github.get(%URI{path: "/user"}, %{token: "BAD_TOKEN"})

          assert Jason.decode(body) ==
                   {:ok,
                    %{
                      "message" => "Bad credentials",
                      "documentation_url" => "https://docs.github.com/rest"
                    }}
        end)

      assert log =~ "[warning]"
      assert log =~ "limit="
      assert log =~ "reset_at="
      assert log =~ "used="
      assert log =~ "remaining="
    end
  end
end
