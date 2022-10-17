defmodule PrZero.State.ReposTest do
  use ExUnit.Case
  alias Plug.Conn
  alias PrZero.State.{Repos, Supervisors, User, Users}
  alias PrZero.Github

  @file_path "./test/mocks/repos.json"
             |> Path.relative_to_cwd()
             |> Path.expand()

  @mock_data File.read!(@file_path)

  defp mock_github_response(%Conn{req_headers: headers} = conn, token) do
    case Enum.into(headers, %{}) do
      %{"authorization" => "Bearer " <> ^token} ->
        Conn.send_resp(conn, 200, @mock_data)

      %{} ->
        Conn.send_resp(
          conn,
          :forbidden,
          Jason.encode!(%{error: :invalid_token, headers: headers})
        )
    end
  end

  describe "PrZero.State.Repos.get/1" do
    setup %{test: test} do
      # token = TestHelpers.get_test_token()
      token = Atom.to_string(test)
      bypass = Bypass.open()
      TestHelpers.set_github_host(bypass)
      Bypass.expect_once(bypass, &mock_github_response(&1, token))
      {:ok, pid} = DynamicSupervisor.start_child(Supervisors.Repos, {Repos, token: token})
      user = %User{repos: pid}
      {:ok, ^user} = Users.add_user({:ok, user}, token)
      {:ok, token: token, user: user}
    end

    # @tag :skip
    test "gets all repos available to the token", %{token: token} do
      assert [%Github.Repo{} | _] = content = Repos.all(token)
    end

    @tag :skip
    test "record data for mocks", %{token: token} do
      Application.put_env(:pr_zero, :write_mock_file?, true)
      assert File.rm(@file_path) == :ok
      assert [%Github.Repo{} | _] = content = Repos.all(token)
      assert File.exists?(@file_path)
    end
  end
end
