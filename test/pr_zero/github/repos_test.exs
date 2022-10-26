defmodule PrZero.Github.ReposTest do
  use PrZero.GithubCase

  alias PrZero.Github.{
    Repo,
    Repos,
    User
  }

  @tag mock: false
  @tag :skip
  test "record response for mocks", %{user: user} do
    TestHelpers.setup_to_record_mock("")
    assert {:ok, _} = Repos.get(user)
    TestHelpers.setup_to_record_mock("")
  end

  describe "Repos.orgs_repos/1" do
    @tag mock: :all
    test "returns all repos for all organizations that the user belongs to", %{token: token} do
      assert {:ok, user} = User.get(token)

      assert {:ok, [%Repo{} | _]} = Repos.get(user)
    end
  end
end
