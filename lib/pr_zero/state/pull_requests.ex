defmodule PrZero.State.PullRequests do
  alias PrZero.{Github, State}

  use State.Server,
    key: :pull_requests,
    github_endpoint: Github.Pulls

  @impl State.Server
  def start_link([token: _, repos_pid: _] = opts) do
    super(opts)
  end

  @impl State.Server
  def fetch(
        %{token: token, repos_pid: repos_pid},
        %State.Server{} = state
      ) do
    case GenServer.call(repos_pid, :all) do
      [_ | _] = repos ->
        Map.put(state, :data, Map.update!(state, :data, &fetch_for_repos(&1, repos, token)))

      {:error, %{}} ->
        Logger.warn("error=repos_not_available token=#{token}")
        state
    end
  end

  defp fetch_for_repos(%{} = old_data, [%Github.Repo{} | _] = repos, "" <> token) do
    Enum.reduce(repos, old_data, &fetch_for_repo(&1, &2, token))
  end

  defp fetch_for_repo(
         %Github.Repo{owner: %Github.Owner{login: "" <> org_name}, name: "" <> repo_name},
         %{} = data,
         "" <> token
       ) do
    {:ok, pulls} =
      Github.Pulls.get(token, %{
        org: org_name,
        repo: repo_name,
        page: 1,
        per_page: 100,
        state: nil
      })

    Enum.reduce(pulls, data, &Map.put(&2, &1.id, &1))
  end
end
