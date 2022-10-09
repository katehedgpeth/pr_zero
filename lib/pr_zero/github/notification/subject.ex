defmodule PrZero.Github.Notification.Subject do
  use PrZero.Github.ResponseParser, keys: [:latest_comment_url, :title, :type, :url]
end
