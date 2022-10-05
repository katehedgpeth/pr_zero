defmodule PrZero.Github.UserTest do
  use ExUnit.Case
  alias PrZero.Github
  alias PrZero.Github.User
  alias User.Urls

  describe "Github.User.get/1" do
    setup do
      TestHelpers.set_github_host(:github)

      {:ok, token: TestHelpers.get_test_token()}
    end

    test "returns a %User{}", %{token: token} do
      assert %{host: "api.github.com"} = Github.base_uri()

      assert {:ok,
              %User{
                id: id,
                name: "" <> _,
                urls: %Urls{
                  events: "" <> _,
                  following: "" <> _,
                  orgs: "" <> _,
                  received_events: "" <> _
                }
              }} = User.get(token: token)

      assert is_number(id)
    end

    test "returns an error if token is bad", %{} do
      assert {:error,
              %HTTPoison.Response{status_code: 401, body: "{\"message\":\"Bad credentials\"" <> _}} =
               User.get(token: "BAD_CODE")
    end
  end
end
