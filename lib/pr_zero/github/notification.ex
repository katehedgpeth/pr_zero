defmodule PrZero.Github.Notification do
  use PrZero.Github.ResponseParser,
    keys: [
      :id,
      :last_read_at,
      :reason,
      :repo,
      :subject,
      :subscription_url,
      :is_unread?,
      :updated_at,
      :url
    ]

  @type reason() :: :comment | :mention | :review_requested | :subscribed
end
