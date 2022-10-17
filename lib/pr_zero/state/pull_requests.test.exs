defmodule PrZero.State.PullRequestsTest do
  use ExUnit.Case
  alias PrZero.State.{PullRequests, User}

  describe "PrZero.State.PullRequests.fetch/2" do
    test "returns a list of pull requests" do
      token = TestHelpers.get_test_token()
      {:ok, pid} = User.start_repos(token)
      assert {:noreply, %{} = pulls} = PullRequests.fetch(%{token: token, repos_pid: pid}, %{})

      # assert {:ok, content} =
      #          pulls
      #          |> Map.values()
      #          |> Jason.encode()

      # assert {:ok, ""} =
      #          File.write(
      #            "./pull_requests.json" |> Path.relative_to_cwd() |> Path.expand(),
      #            content
      #          )
    end
  end
end
