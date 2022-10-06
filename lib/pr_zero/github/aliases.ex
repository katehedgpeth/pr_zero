defmodule PrZero.Github.Aliases do
  defmacro __using__([]) do
    quote do
      alias PrZero.Github

      alias Github.{
        Auth,
        Event,
        Notification,
        Notifications,
        Org,
        Orgs,
        Owner,
        Pulls,
        Pull,
        Repo,
        Repos,
        User
      }
    end
  end
end
