defmodule PrZero.Github.Notifications do
  alias PrZero.Github
  alias Github.Notification
  alias Github.User

  @endpoint "/notifications"
  @mock_file_name :notifications

  def endpoint(), do: @endpoint

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

  def mock_file_path() do
    @mock_file_name
    |> Atom.to_string()
    |> Github.mock_file_path()
  end

  defp parse_response({:ok, notifications}) when is_list(notifications),
    do: {:ok, Enum.map(notifications, &Notification.new/1)}

  defp parse_response(error), do: error
end
