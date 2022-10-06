defmodule PrZero.Github.Event.PullRequestReviewCommentPayload do
  use PrZero.Github.ResponseParser, keys: [:action, :comment, :pull_request]
end
