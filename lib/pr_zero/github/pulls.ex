defmodule PrZero.Github.Pulls do
  use PrZero.Github.Aliases

  @mock_file_name :pull_requests

  def endpoint(%{owner: owner, repo: repo}), do: "/repos/" <> owner <> "/" <> repo <> "/pulls"

  def default_get_query_params(),
    do: %{
      page: 1,
      per_page: 100,
      state: "open"
    }

  def mock_file_name(%{page: page, owner: owner, repo: repo}) do
    [
      Atom.to_string(@mock_file_name),
      owner,
      repo,
      Integer.to_string(page)
    ]
    |> Enum.join("_")
    |> String.to_atom()
  end

  def mock_file_path(%{} = opts) do
    opts
    |> mock_file_name()
    |> Atom.to_string()
    |> Github.mock_file_path()
  end

  def get({:ok, %User{} = user}, opts), do: get(user, opts)

  def get(
        %User{} = user,
        %{owner: "" <> _, repo: "" <> _, page: page, per_page: per_page, state: _string_or_nil} =
          opts
      )
      when is_integer(page) and per_page in 1..100 do
    {path_params, query_params} = Map.split(opts, [:owner, :repo])

    %URI{
      path: endpoint(path_params),
      query: URI.encode_query(query_params)
    }
    |> Github.get(user, mock_file_name(opts))
    |> parse_response()
  end

  defp parse_response({:ok, pulls}), do: {:ok, Enum.map(pulls, &Pull.new/1)}
  defp parse_response({:error, _} = error), do: error
end
