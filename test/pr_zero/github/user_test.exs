defmodule PrZero.Github.UserTest do
  use ExUnit.Case
  alias PrZero.Github

  alias PrZero.Github.{
    Event,
    User
  }

  alias User.Urls

  defp setup do
    TestHelpers.set_github_host(:github)

    {:ok, token: TestHelpers.get_test_token()}
  end

  describe "Github.User.get/1" do
    setup do
      setup()
    end

    @tag :skip
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

    @tag :skip
    test "returns an error if token is bad", %{} do
      assert {:error,
              %HTTPoison.Response{status_code: 401, body: "{\"message\":\"Bad credentials\"" <> _}} =
               User.get(token: "BAD_CODE")
    end
  end

  describe "Github.User.get_received_events/1" do
    setup do
      setup()
    end

    defp validate_received_event(%Event{type: :create} = event) do
      IO.inspect(event)
    end

    defp validate_received_events([page_num | next_page_nums], %User{} = user) do
      assert {:ok, events} = User.get_received_events(user, page: page_num, per_page: 100)
      assert length(events) <= 100

      for event <- events do
        validate_received_event(event)
      end

      assert [%Event{} | _] = events

      if length(events) == 100 do
        validate_received_events(next_page_nums, user)
      end
    end

    test "returns a list of all events", %{token: token} do
      assert {:ok, user} = User.get(token: token)

      1..10
      |> Enum.into([])
      |> validate_received_events(user)
    end
  end
end
