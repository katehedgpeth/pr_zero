defmodule PrZero.Github.UserTest do
  use PrZero.GithubCase

  describe "Github.User.get/1" do
    @tag mock: [User]
    test "returns a %User{} with a token", %{token: token} do
      assert %{host: "localhost"} = Github.base_uri()

      assert {:ok,
              %User{
                id: id,
                name: "" <> _,
                token: ^token
              }} = User.get(token)

      assert is_number(id)
    end

    @tag mock: [User]
    test "returns an error if token is bad", %{} do
      assert {:error, %HTTPoison.Response{status_code: 401, body: body}} = User.get("BAD_CODE")

      assert {:ok, %{"message" => "Bad credentials"}} = Jason.decode(body)
    end

    @tag mock: false
    @tag :skip
    test "record response for mocks", %{token: token} do
      path = User.mock_file_path()

      assert TestHelpers.setup_to_record_mock(path) == :ok
      assert {:ok, _} = User.get(token)

      assert TestHelpers.teardown_after_record_mock(path) == true
    end
  end

  # describe "Github.User.get_received_events/1" do
  #   defp validate_event_type(type)
  #        when type in [
  #               :create,
  #               :issue_comment,
  #               :delete,
  #               :push,
  #               :pull_request_review_comment,
  #               :pull_request
  #             ],
  #        do: true

  #   defp validate_received_event(%Event{} = event) do
  #     validate_event_type(event.type)
  #   end

  #   defp validate_received_events([page_num | next_page_nums], %User{} = user) do
  #     assert {:ok, events} = User.get_received_events(user, page: page_num, per_page: 100)
  #     assert length(events) <= 100

  #     for event <- events do
  #       validate_received_event(event)
  #     end

  #     assert [%Event{} | _] = events

  #     if length(events) == 100 do
  #       validate_received_events(next_page_nums, user)
  #     end
  #   end

  #   @tag mock: [User]
  #   test "returns a list of all events", %{token: token} do
  #     assert {:ok, user} = User.get(token: token)

  #     1..10
  #     |> Enum.into([])
  #     |> validate_received_events(user)
  #   end
  # end
end
