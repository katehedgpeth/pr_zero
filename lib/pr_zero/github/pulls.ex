defmodule PrZero.Github.Pulls do
  use PrZero.Github.Aliases

  defp endpoint(%{owner: owner, repo: repo}), do: "/repos/" <> owner <> "/" <> repo <> "/pulls"

  def default_get_query_params(),
    do: %{
      page: 1,
      per_page: 100,
      state: "open"
    }

  def get(
        %User{} = user,
        %{owner: _, repo: _, page: _, per_page: _, state: _} = opts
      ) do
    {path_params, query_params} = Map.split(opts, [:owner, :repo])

    %URI{
      path: endpoint(path_params),
      query: URI.encode_query(query_params)
    }
    |> Github.get(user)
    |> parse_response()
  end

  defp parse_response({:ok, pulls}), do: {:ok, Enum.map(pulls, &Pull.new/1)}
  defp parse_response({:error, _} = error), do: error
end
