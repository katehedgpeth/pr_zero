defmodule PrZero.Github.Event.IssueCommentPayload do
  use PrZero.Github.ResponseParser, keys: [:action, :comment, :issue]
end
