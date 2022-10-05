defmodule PrZero.Github.Notification.Subject do
  defstruct [:latest_comment_url, :title, :type, :url]

  def new(%{
        "latest_comment_url" => latest_comment_url,
        "title" => title,
        "type" => type,
        "url" => url
      }),
      do: %__MODULE__{
        latest_comment_url: latest_comment_url,
        title: title,
        type: type_atom(type),
        url: url
      }

  defp type_atom("PullRequest"), do: :pull_request
  defp type_atom("Release"), do: :release
end
