defmodule PrZeroWeb.NotificationsChannelTest do
  use PrZero.GithubCase
  alias Phoenix.ChannelTest
  alias Phoenix.Socket
  alias PrZero.State
  require ChannelTest
  alias PrZeroWeb.NotificationsChannel

  @endpoint PrZeroWeb.Endpoint

  describe "&NotificationsChannel.join/3" do
    # @moduletag mock: [
    #              User,
    #              Notifications,
    #              Orgs,
    #              {Repos, "/orgs/insurify/repos"},
    #              {Repos, "/orgs/kate-test-org/repos"},
    #              {Pulls, }
    #            ]
    setup do
      token = TestHelpers.get_test_token()

      {:ok, %State.User{} = user} =
        token
        |> User.get()
        |> State.Users.create()

      {:ok, token: token, user: user}
    end

    test "allows a socket to join if its token matches the user's token", %{
      token: token,
      user: user
    } do
      assert {:ok, %{}, %Socket{} = socket} =
               PrZeroWeb.Socket
               |> ChannelTest.socket(token, %{user: user})
               |> ChannelTest.subscribe_and_join(NotificationsChannel, "notifications:" <> token)

      assert State.Notifications.subscribers(user.notifications) == [socket.channel_pid]
      ChannelTest.assert_push("updated_data", %{notifications: [%Github.Notification{} | _]})
    end

    test "does not allow a socket to join if its token does not match the user's token", %{
      token: token,
      user: user
    } do
      user = Map.update!(user, :user_data, &Map.update!(&1, :token, fn _ -> "BAD_TOKEN" end))

      assert {:error, %{reason: :not_authorized}} =
               PrZeroWeb.Socket
               |> ChannelTest.socket(token, %{user: user})
               |> ChannelTest.subscribe_and_join(NotificationsChannel, "notifications:" <> token)
    end
  end
end
