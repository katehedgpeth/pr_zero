defmodule PrZero.Github.Org do
  use PrZero.Github.ResponseParser,
    keys: [
      :avatar_url,
      :description,
      :events_url,
      :gravatar_id,
      :hooks_url,
      :id,
      :issues_url,
      :login,
      :members_url,
      :node_id,
      :public_members_url,
      :repos_url,
      :url
    ]
end
