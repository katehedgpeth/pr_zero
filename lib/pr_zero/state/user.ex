defmodule PrZero.State.User do
  alias PrZero.State.{Supervisors, Notifications, Repos, PullRequests}

  @type t() :: %__MODULE__{
          notifications: pid(),
          repos: pid(),
          pull_requests: pid()
        }

  defstruct [:notifications, :repos, :pull_requests]

  def new() do
    {:ok, notifications} =
      DynamicSupervisor.start_child(
        Supervisors.Notifications,
        Notifications
      )

    {:ok, repos} = DynamicSupervisor.start_child(Supervisors.Repos, Repos)

    {:ok, pull_requests} = DynamicSupervisor.start_child(Supervisors.PullRequests, PullRequests)

    {:ok, %__MODULE__{notifications: notifications, repos: repos, pull_requests: pull_requests}}
  end

  def stop(%__MODULE__{notifications: notifications, repos: repos, pull_requests: pull_requests}) do
    [
      [Supervisors.Notifications, notifications],
      [Supervisors.PullRequests, pull_requests],
      [Supervisors.Repos, repos]
    ]
    |> Enum.map(&Kernel.apply(DynamicSupervisor, :terminate_child, &1))
    |> case do
      [:ok, :ok, :ok] -> :ok
      error -> {:error, error}
    end
  end
end
