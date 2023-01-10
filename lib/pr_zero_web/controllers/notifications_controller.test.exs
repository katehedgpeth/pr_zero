defmodule PrZeroWeb.NotificationsControllerTest do
  use PrZeroWeb.ConnCase
  use PrZero.GithubCase
  alias Plug.Conn
  alias PrZero.State

  # @orgs ["insurify", "kate-test-org"]

  # @repos %{
  #   "insurify" => ["ensurify"],
  #   "kate-test-org" => ["pr_zero"]
  # }

  def mock_file_path(Pulls, %{mock: [{Pulls, path} | _]}) do
    ["", owner, repo, _] = String.split(path, "/")

    Pulls.default_get_query_params()
    |> Map.merge(%{owner: owner, repo: repo})
    |> Pulls.mock_file_path()
  end

  def mock_file_path(Pulls, tags) do
    IO.inspect(tags)
    super(Pulls, tags)
  end

  describe "GET /notifications" do
    # @tag mock:
    #        Enum.reduce(
    #          @orgs,
    #          [User, Notifications],
    #          fn org, acc1 ->
    #            @repos
    #            |> Map.fetch!(org)
    #            |> Enum.reduce(
    #              [{Repos, "/orgs/#{org}/repos"} | acc1],
    #              fn repo, acc2 -> [{Pulls, "/#{org}/#{repo}/pulls"} | acc2] end
    #            )
    #          end
    #        )
    test "it fetches a user if user is not in State", %{conn: conn, token: token} do
      Application.put_env(:pr_zero, :write_mock_file?, true)
      assert State.Users.get(token) == :error

      assert %{"notifications" => [notification | _]} =
               conn
               |> Conn.put_req_header("authorization", "Bearer " <> token)
               |> get(Routes.notifications_path(conn, :index))
               |> json_response(200)

      assert %Notification{} =
               notification
               |> Enum.map(fn {key, val} -> {String.to_atom(key), val} end)
               |> Notification.__struct__()

      assert {:ok, _} = State.Users.get(token)
      assert {:ok, repos} = State.Repos.all(token)
      assert length(repos) == 31
      assert {:ok, pulls} = State.PullRequests.all(token)
      assert length(pulls) == 1
    end
  end
end
