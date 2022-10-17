defmodule PrZero.UsersTest do
  use ExUnit.Case
  alias PrZero.State.{Notifications, Users, User, Supervisors, Repos, PullRequests}
  alias PrZero.Github

  def is_started?(pid, supervisor, module) do
    supervisor
    |> DynamicSupervisor.which_children()
    |> Enum.member?({:undefined, pid, :worker, [module]})
  end

  describe "PrZero.Users" do
    setup %{test: test} do
      {:ok, token: Atom.to_string(test)}
    end

    @tag :skip
    test "is started in Application" do
      assert {:error, {:already_started, pid}} = Users.start_link(name: Users)
      assert %{} = Agent.get(pid, & &1)
    end

    @tag :skip
    test "&get/1 returns {:ok, %User{}} if user exists", %{token: token} do
      assert {:ok, pid} = Users.start_link([])
      new_user = %User{}
      assert Agent.update(pid, Map, :put, [token, new_user]) == :ok
      assert Users.get(token, pid) == {:ok, new_user}
    end

    @tag :skip
    test "&get/1 returns :error if user does not exist", %{token: token} do
      assert Users.get(token) == :error
    end

    test "&create/1 generates a new user that starts GenServers for all user data, and adds it to the state" do
      token = TestHelpers.get_test_token()
      assert Users.get(token) == :error

      assert {:ok, %User{} = user} = Users.create(token)

      assert is_started?(user.notifications, Supervisors.Notifications, Notifications)
      assert is_started?(user.pull_requests, Supervisors.PullRequests, PullRequests)
      assert is_started?(user.repos, Supervisors.Repos, Repos)

      assert [%Github.Notification{} | _] = Notifications.all(token)
      assert [%Github.Repo{} | _] = Repos.all(token)
      assert [%Github.Pull{} | _] = PullRequests.all(token)
    end

    @tag :skip
    test "&remove/1 removes the user from state", %{token: token} do
      assert Users.get(token) == :error
      assert {:ok, user} = Users.create(token)
      assert Users.get(token) == {:ok, user}

      assert is_started?(user.notifications, Supervisors.Notifications, Notifications)

      assert Users.remove(token) == :ok
      assert Users.get(token) == :error
      assert is_pid(user.notifications)
      assert is_pid(user.pull_requests)
      assert is_pid(user.repos)
      refute is_started?(user.notifications, Supervisors.Notifications, Notifications)
      refute is_started?(user.pull_requests, Supervisors.PullRequests, PullRequests)
      refute is_started?(user.repos, Supervisors.Repos, Repos)
    end
  end
end
