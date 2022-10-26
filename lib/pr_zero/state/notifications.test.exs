defmodule PrZero.State.NotificationsTest do
  use PrZero.GithubCase
  alias Plug.Conn
  alias PrZero.State

  @mock_file_path "./test/mocks/notifications.json"
                  |> Path.relative_to_cwd()
                  |> Path.expand()

  describe "PrZero.State.Notifications.fetch/2" do
    @tag mock: :all
    test "fetches notifications and adds them to state", %{token: token} do
      assert State.Notifications.get_interval() == [seconds: 10]

      state = %State.Server{}
      assert %DateTime{} = state.next_fetch

      assert %State.Server{data: notifications, next_fetch: next_fetch} =
               State.Notifications.fetch(%{token: token}, state)

      assert [%Github.Notification{} | _] = Map.values(notifications)

      assert %DateTime{} = next_fetch
      assert DateTime.diff(next_fetch, state.next_fetch, :second) == 10
    end
  end

  describe "PrZero.State.Notifications.handle_cast({:fetch, opts}, state)" do
    test "does not fetch if next_fetch time is in the future", tags do
      state = %State.Server{
        next_fetch: Timex.now() |> Timex.shift(seconds: 10),
        subscribers: [self()]
      }

      assert State.Notifications.handle_cast({:fetch, tags}, state) == {:noreply, state}
      refute_received {:updated_data, _}
      assert_received {:"$gen_cast", {:fetch, ^tags}}
    end

    @tag mock: :all
    test "does fetch if next_fetch time is in the past", tags do
      state = %State.Server{
        next_fetch: Timex.now() |> Timex.shift(seconds: -1),
        subscribers: [self()]
      }

      assert {:noreply, %State.Server{data: data}} =
               State.Notifications.handle_cast({:fetch, tags}, state)

      assert [%Github.Notification{} | _] = Map.values(data)

      assert_received {:updated_data, list}
      assert is_list(list)
      assert Map.values(data) == list
      assert_received {:"$gen_cast", {:fetch, ^tags}}
    end
  end

  describe "PrZero.State.Notifications.find/2" do
    @users_name :users_test
    setup %{token: token} do
      start_link_supervised!({State.Users, name: @users_name})

      {:ok, user} =
        token
        |> PrZero.Github.User.get()
        |> State.Users.create(@users_name)

      {:ok, user: user}
    end

    @tag mock: :all
    test "returns {:ok, %Notification{}} when notification is found", %{
      token: token,
      user: %State.User{notifications: pid}
    } do
      assert {:ok, [%Notification{} = notification | _]} =
               State.Notifications.call({:ok, pid}, :all, token)

      assert State.Notifications.call({:ok, pid}, {:find, notification.id}, token) ==
               {:ok, notification}
    end

    test "returns :error when notification is not found", %{
      token: token,
      user: %State.User{notifications: pid}
    } do
      assert State.Notifications.call({:ok, pid}, {:find, "bad_id"}, token) == :error
    end
  end

  @tag :skip
  test "write mock data file" do
    assert TestHelpers.setup_to_record_mock(@mock_file_path) == :ok

    assert %State.Server{data: notifications} =
             State.Notifications.fetch(%{token: TestHelpers.get_test_token()}, %State.Server{})

    assert [%Github.Notification{} | _] = Map.values(notifications)

    assert TestHelpers.teardown_after_record_mock(@mock_file_path) == true
  end
end
