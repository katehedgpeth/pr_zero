defmodule PrZero.Github.ReposTest do
  use PrZero.GithubCase

  alias PrZero.Github.{
    Repo,
    Repos,
    User
  }

  def get_endpoint_response(Repos, %{mock: [{_, path}]}) do
    path
    |> String.split("/")
    |> Enum.at(2)
    |> Repos.mock_file_path()
    |> File.read!()
  end

  def get_endpoint_response(endpoint, tags), do: super(endpoint, tags)

  @tag mock: false
  @tag :skip
  test "record response for mocks", %{user: user} do
    TestHelpers.setup_to_record_mock("")
    assert {:ok, _} = Repos.get(user)
    TestHelpers.setup_to_record_mock("")
  end

  describe "Repos.orgs_repos/1" do
    @tag mock: [
           User,
           Orgs,
           {Repos, "/orgs/insurify/repos"},
           {Repos, "/orgs/kate-test-org/repos"}
         ]
    test "returns all repos for all organizations that the user belongs to", %{token: token} do
      assert {:ok, user} = User.get(token: token)

      assert {:ok, [%Repo{} | _]} = Repos.get(user)
    end
  end
end
