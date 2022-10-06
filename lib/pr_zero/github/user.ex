defmodule PrZero.Github.User do
  alias PrZero.Github

  alias Github.Event

  use Github.ResponseParser,
    keys: [
      :avatar_url,
      :email,
      :following,
      :following_url,
      :gravatar_id,
      :html_url,
      :id,
      :is_site_admin?,
      :login,
      :name,
      :node_id,
      :organizations_url,
      :received_events_url,
      :token,
      :two_factor_authentication,
      :type,
      :url
    ],
    skip_keys: [
      :bio,
      :blog,
      :company,
      :collaborators,
      :created_at,
      :disk_usage,
      :events_url,
      :followers,
      :followers_url,
      :gists_url,
      :hireable,
      :location,
      :owned_private_repos,
      :plan,
      :total_private_repos,
      :twitter_username,
      :private_gists,
      :public_gists,
      :public_repos,
      :repos_url,
      :starred_url,
      :subscriptions_url,
      :updated_at
    ]

  @type t() :: %__MODULE__{
          email: String.t(),
          id: String.t(),
          login: String.t() | nil,
          name: String.t() | nil,
          token: String.t() | nil,
          following_url: String.t(),
          organizations_url: String.t(),
          two_factor_authentication: boolean(),
          received_events_url: String.t()
        }

  @users_endpoint "/user"

  def endpoint(), do: @users_endpoint

  def get(token: token) do
    %URI{path: @users_endpoint}
    |> Github.get(%{token: token})
    |> parse_get_response(token)
  end

  def get_received_events(%__MODULE__{received_events_url: url} = user,
        page: page,
        per_page: limit
      ) do
    url
    |> URI.parse()
    |> URI.merge(%URI{query: URI.encode_query(page: page, per_page: limit)})
    |> Github.get(user)
    |> parse_received_events_response()
  end

  @spec parse_get_response(Github.parsed_response(), String.t()) ::
          {:ok, t()} | Github.error_response()
  defp parse_get_response({:ok, params}, token) do
    {:ok, params |> new() |> Map.put(:token, token)}
  end

  defp parse_get_response(error, _token), do: error

  defp parse_received_events_response({:ok, raw_events}) when is_list(raw_events) do
    {:ok, Enum.map(raw_events, &Event.new/1)}
  end

  defp parse_received_events_response({:error, error}), do: {:error, error}
end
