defmodule PrZero.State.Repos do
  use PrZero.State.Server,
    key: :repos,
    github_endpoint: PrZero.Github.Repos
end
