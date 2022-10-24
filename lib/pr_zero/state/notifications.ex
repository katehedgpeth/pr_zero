defmodule PrZero.State.Notifications do
  alias PrZero.Github.{Notification, Notification.Subject}
  alias PrZero.State.Server

  use Server,
    key: :notifications,
    github_endpoint: Github.Notifications

  @impl true
  def fetch(%{token: token}, %Server{} = state) do
    updated_state = super(%{token: token}, state)

    updated_state
    |> Map.fetch!(:data)
    |> Map.values()
    |> Enum.map(&fetch_repo_if_not_exists(&1, token))

    updated_state
  end

  defp fetch_repo_if_not_exists(
         %Notification{
           subject: %Subject{url: _url, type: :pull_request}
         } = notification,
         _token
       ) do
    notification
  end

  defp fetch_repo_if_not_exists(%Notification{} = notification, _token) do
    notification
  end
end
