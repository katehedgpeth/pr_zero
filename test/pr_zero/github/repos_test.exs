defmodule PrZero.Github.ReposTest do
  use PrZero.GithubCase

  alias PrZero.Github.{
    Repo,
    Repos,
    User
  }

  describe "Repos.orgs_repos/1" do
    @tag :external
    test "returns all repos for all organizations that the user belongs to", %{token: token} do
      assert {:ok, user} = User.get(token: token)

      assert {:ok, [%Repo{} | _]} = Repos.all(user)
    end
  end
end
