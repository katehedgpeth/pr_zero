defmodule PrZero.State.User do
  alias PrZero.State.{Supervisors, Notifications, Repos, PullRequests}

  @type t() :: %__MODULE__{
          notifications: pid(),
          repos: pid(),
          pull_requests: pid()
        }

  defstruct [:notifications, :repos, :pull_requests]

  def new("" <> token) do
    {:ok, notifications} = start_notifications(token)
    {:ok, repos} = start_repos(token)
    {:ok, pull_requests} = start_pull_requests(token, repos)

    {:ok, %__MODULE__{notifications: notifications, repos: repos, pull_requests: pull_requests}}
  end

  def start_notifications("" <> token),
    do:
      DynamicSupervisor.start_child(
        Supervisors.Notifications,
        {Notifications, [token: token]}
      )

  def start_repos("" <> token),
    do: DynamicSupervisor.start_child(Supervisors.Repos, {Repos, [token: token]})

  def start_pull_requests("" <> token, repos) when is_pid(repos),
    do:
      DynamicSupervisor.start_child(
        Supervisors.PullRequests,
        {PullRequests, [token: token, repos_pid: repos]}
      )

  def stop(%__MODULE__{notifications: notifications, repos: repos, pull_requests: pull_requests}) do
    [
      [Supervisors.Notifications, notifications],
      [Supervisors.PullRequests, pull_requests],
      [Supervisors.Repos, repos]
    ]
    |> Enum.map(&Kernel.apply(DynamicSupervisor, :stop, &1))
    |> case do
      [:ok, :ok, :ok] -> :ok
      error -> {:error, error}
    end
  end
end
