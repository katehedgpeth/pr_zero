defmodule PrZero.Github.Event do
  alias __MODULE__.{
    CreatePayload,
    DeletePayload,
    IssueCommentPayload,
    PullRequestPayload,
    PullRequestReviewCommentPayload,
    PushPayload
  }

  defstruct [:id, :type, :actor, :payload, :is_public?, :created_at]

  @event_types [
    {:create, "CreateEvent", CreatePayload},
    {:delete, "DeleteEvent", DeletePayload},
    {:issue_comment, "IssueCommentEvent", IssueCommentPayload},
    {:pull_request, "PullRequestEvent", PullRequestPayload},
    {:pull_request_review_comment, "PullRequestReviewCommentEvent",
     PullRequestReviewCommentPayload},
    {:push, "PushEvent", PushPayload}
  ]

  for {event_atom, event_string, payload_module} <- @event_types do
    defp event_type(unquote(event_string)), do: unquote(event_atom)

    defp parse_payload(%__MODULE__{type: unquote(event_atom)} = event, payload),
      do: %{event | payload: unquote(payload_module).new(payload)}
  end

  def new(%{
        "id" => id,
        "type" => type,
        "actor" => actor,
        "payload" => payload,
        "public" => is_public?,
        "created_at" => created_at
      }) do
    %__MODULE__{
      id: id,
      type: event_type(type),
      actor: actor,
      is_public?: is_public?,
      created_at: NaiveDateTime.from_iso8601!(created_at)
    }
    |> parse_payload(payload)
  end
end
