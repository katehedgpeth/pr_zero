defmodule PrZero.Github.PullsTest do
  use PrZero.GithubCase

  @moduletag params:
               Pulls.default_get_query_params()
               |> Map.merge(%{owner: "insurify", repo: "ensurify"})

  def mock_file_path(Pulls, %{params: params}) do
    Pulls.mock_file_path(params)
  end

  def mock_file_path(endpoint, tags), do: super(endpoint, tags)

  def get_endpoint(Pulls, %{params: params}) do
    Pulls.endpoint(params)
  end

  def get_endpoint(endpoint, tags), do: super(endpoint, tags)

  describe "PrZero.Github.Pulls.get/2" do
    @describetag mock: [User, Pulls]
    test "returns a list of all pull requests", %{user: user, params: params} do
      default_params = Pulls.default_get_query_params()
      assert default_params == %{state: "open", page: 1, per_page: 100}

      opts = Map.merge(default_params, params)

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

  @tag mock: false
  @tag :skip
  test "write mock file", %{user: user, params: params} do
    path = Pulls.mock_file_path(params)

    assert TestHelpers.setup_to_record_mock(path) == :ok
    assert {:ok, _} = Pulls.get(user, params)

    TestHelpers.teardown_after_record_mock(path)
  end
end
