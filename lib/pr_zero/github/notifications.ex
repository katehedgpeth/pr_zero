defmodule PrZero.Github.Notifications do
  alias PrZero.Github
  alias Github.Notification
  alias Github.User

  @endpoint "/notifications"
  def get({:ok, %User{} = user}) do
    get(user)
  end

  def get(%User{token: token}) do
    %URI{path: @endpoint}
    |> Github.get(%{token: token})
    |> parse_response()
  end

  defp parse_response({:ok, notifications}) when is_list(notifications),
    do: {:ok, Enum.map(notifications, &Notification.new/1)}

  defp parse_response(error), do: error
end
