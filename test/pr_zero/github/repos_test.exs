defmodule PrZero.Github.ReposTest do
  use ExUnit.Case

  alias PrZero.Github.{
    Repo,
    Repos,
    User
  }

  defp setup() do
    TestHelpers.set_github_host(:github)
    {:ok, token: TestHelpers.get_test_token()}
  end

  describe "Repos.all/1" do
    setup do
      setup()
    end

    test "returns a list of all repos a user has access to ", %{token: token} do
      assert {:ok, user} = User.get(token: token)
      assert user.name == "Kate Hedgpeth"

      assert {:ok, repos} = Repos.all(user)

      assert [%Repo{} | _] = repos
    end
  end

  describe "Repos.orgs_repos/1" do
    setup do
      setup()
    end

    test "returns all repos for all organizations that the user belongs to", %{token: token} do
      assert {:ok, user} = User.get(token: token)

      assert {:ok, repos} = Repos.orgs_repos(user)
      assert Enum.map(repos, & &1.full_name) == []
    end
  end
end
