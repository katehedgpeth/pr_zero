defmodule PrZero.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PrZeroWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: PrZero.PubSub},
      # Start the Endpoint (http/https)
      PrZeroWeb.Endpoint,
      # Start a worker by calling: PrZero.Worker.start_link(arg)
      {PrZero.State.Users, name: PrZero.State.Users},
      {DynamicSupervisor, name: PrZero.State.Supervisors.Notifications},
      {DynamicSupervisor, name: PrZero.State.Supervisors.Repos},
      {DynamicSupervisor, name: PrZero.State.Supervisors.PullRequests}
      # {PrZero.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PrZero.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrZeroWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
