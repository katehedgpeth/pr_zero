defmodule PrZero.Github.Notification do
  alias PrZero.Github.Repo
  alias __MODULE__.Subject

  @type reason() :: :subscribed | :comment
  defstruct [
    :id,
    :last_read_at,
    :reason,
    :repo,
    :subject,
    :subscription_url,
    :unread?,
    :updated_at,
    :url
  ]

  def new(%{
        "id" => id,
        "repository" => repo,
        "subject" => subject,
        "reason" => reason,
        "unread" => unread,
        "updated_at" => updated_at,
        "last_read_at" => last_read_at,
        "url" => url,
        "subscription_url" => subscription_url
      }),
      do: %__MODULE__{
        id: id,
        repo: Repo.new(repo),
        subject: Subject.new(subject),
        reason: parse_reason(reason),
        unread?: unread,
        updated_at: parse_date_time(updated_at),
        last_read_at: parse_date_time(last_read_at),
        url: url,
        subscription_url: subscription_url
      }

  defp parse_date_time(nil), do: nil

  defp parse_date_time("" <> datetime), do: NaiveDateTime.from_iso8601!(datetime)

  defp parse_reason("subscribed"), do: :subscribed
  defp parse_reason("comment"), do: :comment
end
