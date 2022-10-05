defmodule PrZero.Github.Event.IssueCommentPayload do
  alias PrZero.Github.Event.Payload
  use Payload, keys: [:action, :comment, :issue]

  # def new(%{} = payload) do
  #   payload
  #   |> Enum.map(&parse_value/1)
  #   |> __MODULE__.__struct__()
  # end

  # defp parse_value({"action", action}), do: {:action, action}
  # defp parse_value({"comment", comment}), do: {:comment, comment}
  # defp parse_value({"issue", issue}), do: {:issue, issue}
end
