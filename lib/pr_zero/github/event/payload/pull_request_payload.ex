defmodule PrZero.Github.Event.PullRequestPayload do
  use PrZero.Github.ResponseParser, keys: [:action, :before, :number, :pull_request]
end
