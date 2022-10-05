defmodule PrZero.Github.Event.PullRequestReviewCommentPayload do
  alias PrZero.Github.Event.Payload
  use Payload, keys: [:action, :comment, :pull_request]
end
