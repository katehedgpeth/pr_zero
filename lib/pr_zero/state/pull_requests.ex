defmodule PrZero.State.PullRequests do
  alias PrZero.Github

  use PrZero.State.Server,
    key: :pull_requests,
    github_endpoint: PrZero.Github.Pulls

  def fetch(%{token: token, repos_pid: repos_pid}, state) do
    case GenServer.call(repos_pid, {:all, token}) do
      [_ | _] = repos ->
        new_state = Enum.reduce(repos, state, &fetch_for_repo(&1, &2, token))
        {:noreply, new_state}

      {:error, %{}} ->
        Logger.warn("error=repos_not_available token=#{token}")
        {:noreply, state}
    end
  end

  defp fetch_for_repo(
         %Github.Repo{owner: %Github.Owner{login: org_name}, name: repo_name},
         %{} = state,
         token
       ) do
    {:ok, pulls} =
      %Github.User{token: token}
      |> Github.Pulls.get(%{
        owner: org_name,
        repo: repo_name,
        page: 1,
        per_page: 100,
        state: nil
      })

    Enum.reduce(pulls, state, &Map.put(&2, &1.id, &1))
  end
end
