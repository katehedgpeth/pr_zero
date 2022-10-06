defmodule PrZero.Github.OrgsTest do
  use PrZero.GithubCase

  describe "Orgs.all/1" do
    @tag :external
    test "returns a list of all repos a user has access to ", %{token: token} do
      assert {:ok, user} = User.get(token: token)
      assert user.name == "Kate Hedgpeth"

      assert {:ok, orgs} = Orgs.all(user)

      assert length(orgs) > 0
      assert [%Org{} | _] = orgs
    end
  end
end
