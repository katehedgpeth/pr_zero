defmodule PrZero.State.User do
  alias PrZero.Github
  alias PrZero.State.{Supervisors, Notifications, Repos, PullRequests}

  @type t() :: %__MODULE__{
          user_data: Github.User.t(),
          notifications: pid(),
          repos: pid(),
          pull_requests: pid()
        }

  defstruct [:notifications, :repos, :pull_requests, :user_data]

  def supervisor_options(%Github.User{token: token}), do: [token: token]

  def supervisor_options(%Github.User{token: token}, repos_pid) when is_pid(repos_pid),
    do: [token: token, repos_pid: repos_pid]

  def new(%Github.User{} = user) do
    {:ok, notifications} = start_notifications(user)
    {:ok, repos} = start_repos(user)
    {:ok, pull_requests} = start_pull_requests(user, repos)

    {:ok,
     %__MODULE__{
       notifications: notifications,
       repos: repos,
       pull_requests: pull_requests,
       user_data: user
     }}
  end

  def start_notifications(user),
    do:
      DynamicSupervisor.start_child(
        Supervisors.Notifications,
        {Notifications, supervisor_options(user)}
      )

  def start_repos(user),
    do: DynamicSupervisor.start_child(Supervisors.Repos, {Repos, supervisor_options(user)})

  def start_pull_requests(user, repos),
    do:
      DynamicSupervisor.start_child(
        Supervisors.PullRequests,
        {PullRequests, supervisor_options(user, repos)}
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
