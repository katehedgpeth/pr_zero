defmodule PrZero.Github.PullsTest do
  use PrZero.GithubCase

  @moduletag params:
               Pulls.default_get_query_params()
               |> Map.merge(%{org: "insurify", repo: "ensurify"})

  describe "PrZero.Github.Pulls.get/2" do
    @tag mock: :all
    test "returns a list of all pull requests", %{user: user, params: params} do
      default_params = Pulls.default_get_query_params()
      assert default_params == %{state: "open", page: 1, per_page: 100}

      assert {:ok, pulls} = Pulls.get(user, params)

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

  @tag mock: false
  @tag :skip
  test "write mock file", %{user: user, params: params} do
    path = Pulls.mock_file_path(params)

    assert TestHelpers.setup_to_record_mock(path) == :ok
    assert {:ok, _} = Pulls.get(user, params)

    TestHelpers.teardown_after_record_mock(path)
  end
end
