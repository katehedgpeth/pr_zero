defmodule PrZero.Github.OrgsTest do
  use PrZero.GithubCase

  describe "Orgs.get/1" do
    @tag mock: [User, Orgs]
    test "returns a list of all repos a user has access to ", %{token: token} do
      assert {:ok, user} = User.get(token)
      assert user.name == "Kate Hedgpeth"

      assert {:ok, orgs} = Orgs.get(user)

      assert length(orgs) > 0
      assert [%Org{} | _] = orgs
    end

    @tag :skip
    @tag mock: false
    test "record response for mocks", %{user: user} do
      path = Orgs.mock_file_path()

      with :ok <- TestHelpers.setup_to_record_mock(path) do
        assert {:ok, _} = Orgs.get(user)
      end

      assert TestHelpers.teardown_after_record_mock(path) == true
    end
  end
end
