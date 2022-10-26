defmodule PrZero.Github.Pulls do
  @behaviour PrZero.Github.Endpoint
  use PrZero.Github.Aliases

  @mock_file_name :pull_requests

  @impl Github.Endpoint
  def endpoint(%{org: owner, repo: repo}), do: "/repos/" <> owner <> "/" <> repo <> "/pulls"

  @impl Github.Endpoint
  def mock_file_path(%{} = opts) do
    opts
    |> mock_file_name()
    |> Atom.to_string()
    |> Github.mock_file_path()
  end

  def default_get_query_params(),
    do: %{
      page: 1,
      per_page: 100,
      state: "open"
    }

  def mock_file_name(%{org: owner, repo: repo, page: page}) do
    [
      Atom.to_string(@mock_file_name),
      owner,
      repo,
      Integer.to_string(page)
    ]
    |> Enum.join("_")
    |> String.to_atom()
  end

  def mock_file_name(%{org: _, repo: _} = opts) do
    opts
    |> Map.put(:page, 1)
    |> mock_file_name()
  end

  @type get_opts :: %{
          :org => String.t(),
          :page => integer,
          :per_page => 1..255,
          :repo => String.t(),
          :state => any
        }

  @impl Github.Endpoint
  def get(_), do: {:error, :not_implemented}

  @impl Github.Endpoint
  def get({:ok, %User{token: token}}, opts), do: get(token, opts)
  def get(%User{token: token}, opts), do: get(token, opts)

  def get(
        "" <> token,
        %{
          org: "" <> _,
          repo: "" <> _,
          page: page,
          per_page: per_page,
          state: _string_or_nil
        } = opts
      )
      when is_integer(page) and per_page in 1..100 do
    {path_params, query_params} = Map.split(opts, [:org, :repo])

    %URI{
      path: endpoint(path_params),
      query: URI.encode_query(query_params)
    }
    |> Github.get(%{token: token}, mock_file_name(opts))
    |> parse_response()
  end

  defp parse_response({:ok, pulls}), do: {:ok, Enum.map(pulls, &Pull.new/1)}
  defp parse_response({:error, error}), do: {:error, error}
end
