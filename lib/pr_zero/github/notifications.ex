defmodule PrZero.Github.Notifications do
  alias PrZero.Github
  alias Github.Notification
  alias Github.User

  @behaviour Github.Endpoint

  @endpoint "/notifications"
  @mock_file_name :notifications

  def endpoint(_ \\ nil), do: @endpoint

  def mock_file_path(_ \\ nil) do
    @mock_file_name
    |> Atom.to_string()
    |> Github.mock_file_path()
  end

  def get({:ok, %User{token: token}}) do
    get(token)
  end

  def get(%User{token: token}) do
    get(token)
  end

  def get("" <> token) do
    %URI{path: @endpoint}
    |> Github.get(%{token: token}, @mock_file_name)
    |> parse_response()
  end

  defp parse_response({:ok, notifications}) when is_list(notifications),
    do: {:ok, Enum.map(notifications, &Notification.new/1)}

  defp parse_response(error), do: error
end
