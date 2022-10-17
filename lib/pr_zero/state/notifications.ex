defmodule PrZero.State.Notifications do
  alias PrZero.Github.{Notification, Notification.Subject}

  use PrZero.State.Server,
    key: :notifications,
    github_endpoint: Github.Notifications

  def fetch(%{token: token, repo_pid: pid}, state) do
    {:noreply, updated_state} = super(%{token: token, repo_pid: pid}, state)

    updated_state
    |> Map.values()
    |> Enum.map(&fetch_repo_if_not_exists(&1, token))

    {:noreply, updated_state}
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
