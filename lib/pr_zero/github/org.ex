defmodule PrZero.Github.Org do
  defstruct [
    :avatar_url,
    :description,
    :events_url,
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

  def new(%{
        "avatar_url" => avatar_url,
        "description" => description,
        "events_url" => events_url,
        "hooks_url" => hooks_url,
        "id" => id,
        "issues_url" => issues_url,
        "login" => login,
        "members_url" => members_url,
        "node_id" => node_id,
        "public_members_url" => public_members_url,
        "repos_url" => repos_url,
        "url" => url
      }),
      do: %__MODULE__{
        avatar_url: avatar_url,
        description: description,
        events_url: events_url,
        hooks_url: hooks_url,
        id: id,
        issues_url: issues_url,
        login: login,
        members_url: members_url,
        node_id: node_id,
        public_members_url: public_members_url,
        repos_url: repos_url,
        url: url
      }
end
