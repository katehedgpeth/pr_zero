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

  def get_thread(%__MODULE__{url: url}, %User{} = user) do
    %URI{path: path} = URI.parse(url)

    %URI{path: path}
    |> Github.get(user)
    |> parse_thread_response()
  end

  defp parse_thread_response({:ok, json}) do
    IO.inspect(json)
  end
end
