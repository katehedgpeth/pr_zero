defmodule PrZero.Github.User do
  alias PrZero.Github

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
end
