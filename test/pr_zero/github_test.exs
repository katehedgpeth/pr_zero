defmodule PrZero.GithubTest do
  use ExUnit.Case
  alias PrZero.Github

  describe "auth" do
    alias PrZero.Github.Auth

    import PrZero.GithubFixtures

    @invalid_attrs %{}

    test "list_auth/0 returns all auth" do
      auth = auth_fixture()
      assert Github.list_auth() == [auth]
    end

    test "get_auth!/1 returns the auth with given id" do
      auth = auth_fixture()
      assert Github.get_auth!(auth.user_id) == auth
    end

    test "create_auth/1 with valid data creates a auth" do
      valid_attrs = %{}

      assert {:ok, %Auth{} = auth} = Github.create_auth(valid_attrs)
    end

    test "create_auth/1 with invalid data returns error changeset" do
      assert {:error, %{}} = Github.create_auth(@invalid_attrs)
    end

    test "delete_auth/1 deletes the auth" do
      auth = auth_fixture()
      assert {:ok, %Auth{}} = Github.delete_auth(auth)
      assert_raise :no_results, fn -> Github.get_auth!(auth.user_id) end
    end
  end
end
