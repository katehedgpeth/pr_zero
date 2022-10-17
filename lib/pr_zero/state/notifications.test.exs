defmodule PrZero.State.NotificationsTest do
  use PrZero.GithubCase
  alias Plug.Conn
  alias PrZero.State

  @mock_file_path "./test/mocks/notifications.json"
                  |> Path.relative_to_cwd()
                  |> Path.expand()

  @mock_data @mock_file_path |> File.read!()

  # def mock_notifications_response(%Conn{req_headers: headers} = conn, token) do
  #   case Enum.into(headers, %{}) do
  #     %{"authorization" => "Bearer " <> ^token} ->
  #       conn
  #       |> Conn.resp(200, @mock_data)

  #     header_map ->
  #       Conn.resp(
  #         conn,
  #         :forbidden,
  #         Jason.encode!(%{error: :invalid_token, headers: header_map})
  #       )
  #   end
  # end

  describe "PrZero.State.Notifications.fetch/2" do
    # setup %{test: test} do
    #   bypass = Bypass.open()
    #   TestHelpers.set_github_host(bypass)
    #   token = Atom.to_string(test)
    #   Bypass.expect_once(bypass, &mock_notifications_response(&1, token))
    #   {:ok, token: token}
    # end

    @tag mock: [User, Notifications]
    test "fetches notifications and adds them to state", %{token: token} do
      assert {:noreply, notifications} = State.Notifications.fetch(%{token: token}, %{})
      assert length(notifications) == 1
    end
  end

  @tag :skip
  test "write mock data file" do
    assert {:noreply, notifications} =
             State.Notifications.fetch(%{token: TestHelpers.get_test_token()}, %{})

    assert {:ok, json} =
             notifications
             |> Map.values()
             |> Jason.encode()

    assert File.write(@mock_file_path, json)
  end
end
