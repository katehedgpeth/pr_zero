defmodule PrZero.Github.Owner do
  defstruct [
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

  def new(%{
        "avatar_url" => avatar_url,
        "events_url" => events_url,
        "followers_url" => followers_url,
        "following_url" => following_url,
        "gists_url" => gists_url,
        "gravatar_id" => gravatar_id,
        "html_url" => html_url,
        "id" => id,
        "login" => login,
        "node_id" => node_id,
        "organizations_url" => organizations_url,
        "received_events_url" => received_events_url,
        "site_admin" => site_admin,
        "repos_url" => repos_url,
        "starred_url" => starred_url,
        "subscriptions_url" => subscriptions_url,
        "type" => type,
        "url" => url
      }),
      do: %__MODULE__{
        avatar_url: avatar_url,
        events_url: events_url,
        followers_url: followers_url,
        following_url: following_url,
        gists_url: gists_url,
        gravatar_id: gravatar_id,
        html_url: html_url,
        id: id,
        login: login,
        node_id: node_id,
        organizations_url: organizations_url,
        received_events_url: received_events_url,
        is_site_admin?: site_admin,
        repos_url: repos_url,
        starred_url: starred_url,
        subscriptions_url: subscriptions_url,
        type: organization_type(type),
        url: url
      }

  defp organization_type("Organization"), do: :org
end
