defmodule PrZero.State.PullRequests do
  alias PrZero.Github

  use PrZero.State.Server,
    key: :pull_requests,
    github_endpoint: PrZero.Github.Pulls

  @impl true
  def fetch(%{token: token, repos_pid: repos_pid}, state) do
    case GenServer.call(repos_pid, :all) do
      [_ | _] = repos ->
        Map.update!(state, :data, &fetch_for_repos(&1, repos, token))

      {:error, %{}} ->
        Logger.warn("error=repos_not_available token=#{token}")
        state
    end
  end

  defp fetch_for_repos(%{} = state, [%Github.Repo{} | _] = repos, "" <> token) do
    Enum.reduce(repos, state, &fetch_for_repo(&1, &2, token))
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
