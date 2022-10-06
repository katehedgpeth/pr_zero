defmodule PrZero.Github.Event do
  alias __MODULE__.{
    CreatePayload,
    DeletePayload,
    IssueCommentPayload,
    PullRequestPayload,
    PullRequestReviewCommentPayload,
    PushPayload
  }

  @event_types [
    {:create, "CreateEvent", CreatePayload},
    {:delete, "DeleteEvent", DeletePayload},
    {:issue_comment, "IssueCommentEvent", IssueCommentPayload},
    {:pull_request, "PullRequestEvent", PullRequestPayload},
    {:pull_request_review_comment, "PullRequestReviewCommentEvent",
     PullRequestReviewCommentPayload},
    {:push, "PushEvent", PushPayload}
  ]

  use PrZero.Github.ResponseParser,
    keys: [
      :id,
      :actor,
      :created_at,
      :is_public?,
      :org,
      :payload,
      :repo,
      :type
    ]

  for {event_atom, payload_module} <- @event_types do
    def post_new(%__MODULE__{type: unquote(event_atom), payload: raw_payload} = event),
      do: %{event | payload: unquote(payload_module).new(raw_payload)}
  end
end
