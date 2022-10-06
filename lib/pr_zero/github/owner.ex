defmodule PrZero.Github.Owner do
  use PrZero.Github.ResponseParser,
    keys: [
      :avatar_url,
      :events_url,
      :followers_url,
      :following_url,
      :gists_url,
      :gravatar_id,
      :html_url,
      :id,
      :login,
      :node_id,
      :organizations_url,
      :received_events_url,
      :is_site_admin?,
      :repos_url,
      :starred_url,
      :subscriptions_url,
      :type,
      :url
    ]

  @type t() :: %__MODULE__{}
  @type type() :: :organization
end
