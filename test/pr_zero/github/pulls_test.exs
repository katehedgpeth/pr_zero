defmodule PrZero.Github.PullsTest do
  use PrZero.GithubCase

  describe "PrZero.Github.Pulls.get/2" do
    @tag :external
    test "returns a list of all pull requests", %{user: user} do
      default_params = Pulls.default_get_query_params()
      assert default_params == %{state: "open", page: 1, per_page: 100}

      opts = Map.merge(default_params, %{owner: "insurify", repo: "ensurify"})

      assert {:ok, pulls} = Pulls.get(user, opts)

      for pull <- pulls do
        assert %Pull{} = pull

        assert pull.state == :open
        assert %NaiveDateTime{} = pull.created_at
        assert %NaiveDateTime{} = pull.updated_at
        assert pull.merged_at == nil
        assert %User{} = pull.user
      end
    end
  end
end
