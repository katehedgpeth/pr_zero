defmodule PrZero.Github.User do
  alias PrZero.Github

  alias Github.Event

  @type t() :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          token: String.t(),
          urls: __MODULE__.Urls.t()
        }

  defstruct [
    :id,
    :name,
    :token,
    urls: %__MODULE__.Urls{}
  ]

  @users_endpoint "/user"

  def get(token: token) do
    %URI{path: @users_endpoint}
    |> Github.get(%{token: token})
    |> parse_get_response(token)
  end

  def get_received_events(%__MODULE__{urls: %{received_events: url}} = user,
        page: page,
        per_page: limit
      ) do
    url
    |> URI.parse()
    |> URI.merge(%URI{query: URI.encode_query(page: page, per_page: limit)})
    |> Github.get(user)
    |> parse_received_events_response()
  end

  defp parse_get_response(
         {:ok,
          %{
            "id" => id,
            "name" => name,
            "events_url" => events_url,
            "organizations_url" => orgs_url,
            "received_events_url" => received_events_url,
            "following_url" => following_url
          }},
         token
       ) do
    {:ok,
     %__MODULE__{
       id: id,
       name: name,
       token: token,
       urls: %__MODULE__.Urls{
         orgs: orgs_url,
         events: events_url,
         following: following_url,
         received_events: received_events_url
       }
     }}
  end

  defp parse_get_response(error, _token), do: error

  defp parse_received_events_response({:ok, raw_events}) when is_list(raw_events) do
    {:ok, Enum.map(raw_events, &Event.new/1)}
  end

  defp parse_received_events_response({:error, error}), do: {:error, error}
end
