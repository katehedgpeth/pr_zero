defmodule PrZero.Github.ReposTest do
  use ExUnit.Case

  alias PrZero.Github.{
    Orgs,
    Org,
    User
  }

  describe "Orgs.all/1" do
    setup do
      TestHelpers.set_github_host(:github)
      {:ok, token: TestHelpers.get_test_token()}
    end

    test "returns a list of all repos a user has access to ", %{token: token} do
      assert {:ok, user} = User.get(token: token)
      assert user.name == "Kate Hedgpeth"

      assert {:ok, orgs} = Orgs.all(user)

      assert length(orgs) == 0
      assert [%Org{} | _] = orgs
    end
  end
end
